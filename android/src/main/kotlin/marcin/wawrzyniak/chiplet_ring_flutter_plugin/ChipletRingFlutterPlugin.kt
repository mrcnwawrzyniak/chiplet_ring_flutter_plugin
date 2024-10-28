package marcin.wawrzyniak.chiplet_ring_flutter_plugin

import android.app.Application
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.lm.sdk.LmAPI
import com.lm.sdk.inter.IHeartListener
import com.lm.sdk.inter.IResponseListener
import com.lm.sdk.utils.BLEUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ChipletRingFlutterPlugin */
class ChipletRingFlutterPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private lateinit var context: Context

  private lateinit var bluetoothAdapter: BluetoothAdapter
  private lateinit var bluetoothLeScanner: BluetoothLeScanner
  private var macAddress: String? = null

  private val leScanCallback: ScanCallback =
    object : ScanCallback() {
      override fun onScanResult(callbackType: Int, result: ScanResult) {
        super.onScanResult(callbackType, result)
        val device = result.device
        // Emitowanie każdego znalezionego urządzenia do Fluttera
        sendEvent(
          mapOf(
            "event" to "scan_result",
            "name" to (device.name ?: "Nieznane urządzenie"),
            "mac" to device.address
          )
        )
      }

      override fun onScanFailed(errorCode: Int) {
        super.onScanFailed(errorCode)
        sendEvent(mapOf("event" to "scan_failed", "errorCode" to errorCode))
      }
    }

  override fun onAttachedToEngine(
    @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
  ) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "chiplet_ring_flutter_plugin")
    channel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "chiplet_ring_event_channel")
    eventChannel.setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
          eventSink = events
        }

        override fun onCancel(arguments: Any?) {
          eventSink = null
        }
      }
    )

    initializeSdk(context.applicationContext as Application)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initializeSdk" -> {
        initializeSdk(context.applicationContext as Application)
        result.success(null)
      }

      "startScan" -> {
        startScan()
        result.success(null)
      }

      "connectToRing" -> {
        val mac = call.argument<String>("mac")
        if (mac != null) {
          connectToRing(mac)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "MAC address is required", null)
        }
      }

      "getBatteryLevel" -> {
        getBatteryLevel()
        result.success(null)
      }

      "getVersion" -> {
        getVersion()
        result.success(null)
      }

      "syncTime" -> {
        syncTime()
        result.success(null)
      }

      "startHeartRateMeasurement" -> {
        startHeartRateMeasurement()
        result.success(null)
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initializeSdk(application: Application) {
    LmAPI.init(application)
    LmAPI.setDebug(true)

    // Dodanie listenera za pomocą anonimowej implementacji IResponseListener
    LmAPI.addWLSCmdListener(
      context,
      object : IResponseListener {
        override fun lmBleConnecting(i: Int) {
          sendEvent(mapOf("event" to "ble_connecting", "code" to i))
        }

        override fun lmBleConnectionSucceeded(i: Int) {
          BLEUtils.setGetToken(true)
          sendEvent(mapOf("event" to "connected", "code" to i))
        }

        override fun lmBleConnectionFailed(i: Int) {
          sendEvent(mapOf("event" to "connection_failed", "code" to i))
          Handler(Looper.getMainLooper()).post {
            Toast.makeText(context, "Połączenie nie powiodło się", Toast.LENGTH_SHORT).show()
          }
        }

        override fun VERSION(b: Byte, s: String) {
          sendEvent(mapOf("event" to "version_info", "version" to s))
        }

        override fun syncTime(b: Byte, var2: ByteArray) {
          sendEvent(
            mapOf(
              "event" to
                if (b == 0.toByte()) "sync_time_success"
                else "sync_time_failed"
            )
          )
        }

        override fun stepCount(bytes: ByteArray, b: Byte) {
          // Obsługa danych dotyczących kroków, jeśli potrzebne
        }

        override fun battery(b: Byte, b1: Byte) {
          sendEvent(mapOf("event" to "battery_level", "level" to b1.toInt()))
        }

        override fun timeOut() {
          sendEvent(mapOf("event" to "timeout"))
        }

        override fun saveData(s: String) {
          // Obsługa zapisywania danych, jeśli potrzebne
        }

        override fun reset(bytes: ByteArray) {
          // Obsługa resetu, jeśli potrzebne
        }

        override fun collection(bytes: ByteArray, b: Byte) {
          // Obsługa kolekcji danych, jeśli potrzebne
        }

        override fun BPwaveformData(b: Byte, b1: Byte, s: String) {
          // Obsługa danych BP, jeśli potrzebne
        }

        override fun onSport(i: Int, bytes: ByteArray) {
          // Obsługa danych sportowych, jeśli potrzebne
        }

        override fun breathLight(b: Byte) {
          // Obsługa breath light, jeśli potrzebne
        }

        override fun SET_HID(b: Byte) {
          // Obsługa SET_HID, jeśli potrzebne
        }

        override fun GET_HID(b: Byte, b1: Byte, b2: Byte) {
          // Obsługa GET_HID, jeśli potrzebne
        }

        override fun GET_HID_CODE(bytes: ByteArray) {
          // Obsługa GET_HID_CODE, jeśli potrzebne
        }
      }
    )

    val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    bluetoothAdapter = bluetoothManager.adapter
    bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner

    if (bluetoothAdapter == null) {
      Log.e("ChipletRingPlugin", "Bluetooth not supported on this device")
      Handler(Looper.getMainLooper()).post {
        Toast.makeText(
          context,
          "Bluetooth nie jest obsługiwany na tym urządzeniu",
          Toast.LENGTH_SHORT
        )
          .show()
      }
    }
  }

  private fun startScan() {
    if (!bluetoothAdapter.isEnabled) {
      sendEvent(mapOf("event" to "bluetooth_disabled"))
      Handler(Looper.getMainLooper()).post {
        Toast.makeText(
          context,
          "Bluetooth jest wyłączony. Proszę włączyć Bluetooth.",
          Toast.LENGTH_SHORT
        )
          .show()
      }
      return
    }

    if (!isLocationEnabled()) {
      sendEvent(mapOf("event" to "location_disabled"))
      Handler(Looper.getMainLooper()).post {
        Toast.makeText(
          context,
          "Lokalizacja jest wyłączona. Włącz ją, aby kontynuować.",
          Toast.LENGTH_LONG
        )
          .show()
        context.startActivity(
          Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
      }
      return
    }

    bluetoothLeScanner.startScan(leScanCallback)
    sendEvent(mapOf("event" to "scan_started"))
  }

  private fun connectToRing(mac: String) {
    macAddress = mac
    if (!bluetoothAdapter.isEnabled) {
      sendEvent(mapOf("event" to "bluetooth_disabled"))
      Handler(Looper.getMainLooper()).post {
        Toast.makeText(
          context,
          "Bluetooth jest wyłączony. Proszę włączyć Bluetooth.",
          Toast.LENGTH_SHORT
        )
          .show()
      }
      return
    }

    // Zatrzymanie skanowania przed połączeniem
    bluetoothLeScanner.stopScan(leScanCallback)

    val device: BluetoothDevice? = bluetoothAdapter.getRemoteDevice(macAddress)
    if (device != null) {
      BLEUtils.connectLockByBLE(context, device)
      sendEvent(mapOf("event" to "connecting", "mac" to mac))
    } else {
      sendEvent(mapOf("event" to "device_not_found", "mac" to mac))
    }
  }

  private fun isLocationEnabled(): Boolean {
    val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
      locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
  }

  private fun getBatteryLevel() {
    LmAPI.GET_BATTERY(0x00)
  }

  private fun getVersion() {
    LmAPI.GET_VERSION(0x00)
  }

  private fun syncTime() {
    LmAPI.SYNC_TIME()
  }

  private fun startHeartRateMeasurement() {
    LmAPI.GET_HEART_ROTA(
      1,
      object : IHeartListener {
        override fun progress(progress: Int) {
          sendEvent(mapOf("event" to "heart_rate_progress", "progress" to progress))
        }

        override fun resultData(heart: Int, heartRota: Int, yaLi: Int, temp: Int) {
          sendEvent(
            mapOf(
              "event" to "heart_rate_result",
              "heart" to heart,
              "heartRota" to heartRota,
              "yaLi" to yaLi,
              "temp" to temp
            )
          )
        }

        override fun waveformData(seq: Byte, number: Byte, s: String) {
          sendEvent(
            mapOf(
              "event" to "heart_rate_waveform",
              "seq" to seq.toInt(),
              "number" to number.toInt(),
              "data" to s
            )
          )
        }

        override fun error(value: Int) {
          sendEvent(mapOf("event" to "heart_rate_error", "value" to value))
        }

        override fun success() {
          sendEvent(mapOf("event" to "heart_rate_success"))
        }
      }
    )
  }

  private fun sendEvent(event: Map<String, Any>) {
    Handler(Looper.getMainLooper()).post { eventSink?.success(event) }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    LmAPI.removeWLSCmdListener(context)
    bluetoothLeScanner.stopScan(leScanCallback)
  }
}
