package marcin.wawrzyniak.chiplet_ring_flutter_plugin;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import java.util.ArrayList;
import java.util.List;

public class BaseActivity extends AppCompatActivity {
  private int REQUEST_CODE_PERMISSION = 0x00099;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
  }

  public void requestPermission(String[] permissions, int requestCode) {
    this.REQUEST_CODE_PERMISSION = requestCode;
    if (checkPermissions(permissions)) {
      permissionSuccess(REQUEST_CODE_PERMISSION);
    } else {
      List<String> needPermissions = getDeniedPermissions(permissions);
      ActivityCompat.requestPermissions(this, needPermissions.toArray(new String[needPermissions.size()]),
          REQUEST_CODE_PERMISSION);
    }
  }

  public boolean checkPermissions(String[] permissions) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      return true;
    }

    for (String permission : permissions) {
      if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
        return false;
      }
    }
    return true;
  }

  private List<String> getDeniedPermissions(String[] permissions) {
    List<String> needRequestPermissionList = new ArrayList<>();
    for (String permission : permissions) {
      if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED ||
          ActivityCompat.shouldShowRequestPermissionRationale(this, permission)) {
        needRequestPermissionList.add(permission);
      }
    }
    return needRequestPermissionList;
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    if (requestCode == REQUEST_CODE_PERMISSION) {
      if (verifyPermissions(grantResults)) {
        permissionSuccess(REQUEST_CODE_PERMISSION);
      } else {
        permissionFail(REQUEST_CODE_PERMISSION);
        showTipsDialog();
      }
    }
  }

  private boolean verifyPermissions(int[] grantResults) {
    for (int grantResult : grantResults) {
      if (grantResult != PackageManager.PERMISSION_GRANTED) {
        return false;
      }
    }
    return true;
  }

  private void showTipsDialog() {
    // TODO 提示用户未授权
  }

  private void startAppSettings() {
    Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
    intent.setData(Uri.parse("package:" + getPackageName()));
    startActivity(intent);
  }

  public void permissionSuccess(int requestCode) {
  }

  public void permissionFail(int requestCode) {
  }
}
