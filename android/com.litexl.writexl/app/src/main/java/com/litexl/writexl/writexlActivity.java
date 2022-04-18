package com.litexl.writexl;

import org.libsdl.app.SDLActivity;
import android.content.res.AssetManager;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import android.os.Bundle;
import android.util.Log;
import android.os.Environment;
import android.view.View;
import android.app.ActionBar;
import android.view.WindowManager;
import android.view.WindowInsetsController;
import android.view.WindowInsets;
import java.io.File;

public class writexlActivity extends SDLActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        String prefix = getExternalFilesDir(null) + "";
        String userdir = getExternalFilesDir("user") + "";
        try {
            copyDirectoryOrFile(getAssets(), "data", getExternalFilesDir("share") + "/lite-xl");
            copyDirectoryOrFile(getAssets(), "user", userdir + "/lite-xl");
        } catch (IOException e) {
            Log.e("assetManager", "Failed to copy assets: " + e.getMessage());
        }
        super.onCreate(savedInstanceState);
        Log.i("litexl", "Setting LITE_PREFIX to " + prefix);
        nativeSetenv("LITE_PREFIX", prefix);
        Log.i("litexl", "Setting HOME to " + prefix);
        nativeSetenv("HOME", prefix);
        Log.i("litexl", "Setting LITE_SCALE to 1.0");
        nativeSetenv("LITE_SCALE", "2.0");
        Log.i("litexl", "Setting XDG_CONFIG_HOME to " + userdir);
        nativeSetenv("XDG_CONFIG_HOME", userdir);
        
        getWindow().setDecorFitsSystemWindows(false);
        WindowInsetsController controller = getWindow().getInsetsController();
        if (controller != null) {
            controller.hide(WindowInsets.Type.statusBars() | WindowInsets.Type.navigationBars());
            controller.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        }
    }
    
    private void copyDirectoryOrFile(AssetManager assetManager, String source, String target) throws IOException {
        Log.i("assetManager", "Copying assets from " + source);
        String[] files = assetManager.list(source);
        String transformedTarget = target + "/" + source.substring(source.indexOf("/") + 1);
        if (files.length == 0) {
            Log.i("assetManager", "Copying file " + source + " to " + transformedTarget);
            InputStream in = assetManager.open(source);
            FileOutputStream out = new FileOutputStream(transformedTarget);
            byte[] buffer = new byte[1024];
            int read;
            while((read = in.read(buffer)) != -1){
                out.write(buffer, 0, read);
            }
            in.close();
            out.flush();
            out.close();
        } else {
            Log.i("assetManager", "Copying directory " + source + " to " + transformedTarget);
            File directory = new File(transformedTarget);
            if (!directory.exists() && !directory.mkdirs())
                throw new IOException("Can't make directory " + transformedTarget);
            for (String file : files)
                copyDirectoryOrFile(assetManager, source != "" ? source + "/" + file : file, target);
        }
    }
}
