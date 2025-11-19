package pucp.edu.pe.app_tesis;

import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.content.ContentValues;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.app_tesis.storage";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {
            if (call.method.equals("saveToDownloadFolder")) {

                String filename = call.argument("filename");
                byte[] bytes = call.argument("bytes");

                if (filename == null || bytes == null) {
                    result.error("INVALID", "Missing arguments", null);
                    return;
                }

                try {
                    boolean ok = saveToDownloads(filename, bytes);
                    result.success(ok);
                } catch (Exception e) {
                    result.error("ERROR", e.getMessage(), null);
                }

            } else {
                result.notImplemented();
            }
        });
    }

    private static final String TAG = "ExcelExport";

    private boolean saveToDownloads(String filename, byte[] bytes) throws Exception {

        // Android 10 and above: use MediaStore API
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContentValues values = new ContentValues();
            values.put(MediaStore.Downloads.DISPLAY_NAME, filename);
            values.put(MediaStore.Downloads.MIME_TYPE,
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            values.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
            values.put(MediaStore.Downloads.IS_PENDING, 1);

            android.net.Uri uri = getContentResolver().insert(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    values
            );
            if (uri == null) {
                Log.e(TAG, "MediaStore URI insertion failed.");
                return false;
            }

            try (OutputStream out = getContentResolver().openOutputStream(uri)) {
                if (out == null) {
                    Log.e(TAG, "OutputStream is null.");
                    return false;
                }
                out.write(bytes);
            } catch (Exception e) {
                Log.e(TAG, "Error writing bytes to MediaStore: " + e.getMessage());
                return false;
            }

            values.clear();
            values.put(MediaStore.Downloads.IS_PENDING, 0);
            int rowsUpdated = getContentResolver().update(uri, values, null, null);
            if (rowsUpdated == 0) {
                Log.e(TAG, "MediaStore update failed (rowsUpdated = 0).");
                return false;
            }

            Log.d(TAG, "MediaStore save successful.");
            return true;
        }

        try {
            // Android 9 and below: save directly to Downloads folder
            File downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
            if (!downloads.exists()) downloads.mkdirs();

            File file = new File(downloads, filename);

            try (FileOutputStream fos = new FileOutputStream(file)) {
                fos.write(bytes);
                fos.flush();
            }
            Log.d(TAG, "Legacy save successful at: " + file.getAbsolutePath());
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Error in legacy save (Android 9-): " + e.getMessage(), e);
            return false;
        }
    }
}
