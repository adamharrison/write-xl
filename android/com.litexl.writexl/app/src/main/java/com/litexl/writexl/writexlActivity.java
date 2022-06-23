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
import android.os.Build;
import java.io.File;

public class writexlActivity extends SDLActivity {
    static String getArchitecturePrefix(String abi) {
        if (abi.indexOf("arm64-v8a") != -1)
            return "aarch64-linux-android";
        if (abi.indexOf("armeabi-") != -1)
            return "armv7a-linux-androideabi";
        if (abi.indexOf("x86_64") != -1)
            return "x86_64-linux-android";
        if (abi.indexOf("x86") !=- 1)
            return "i686-linux-android";
        return null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        String prefix = getExternalFilesDir(null) + "";
        String userdir = getExternalFilesDir("user") + "";
        File file = new File(getExternalFilesDir("files") + "");
        try {
            if (!file.exists() && !file.mkdirs())
                throw new IOException("Can't make directory " + file.getPath());
            copyDirectoryOrFile(getAssets(), "data", getExternalFilesDir("share") + "/lite-xl");
            copyDirectoryOrFile(getAssets(), "user", userdir + "/lite-xl");
            copyFile(getAssets(), "gitsave/" + writexlActivity.getArchitecturePrefix(Build.SUPPORTED_ABIS[0]) + "/native.so" , userdir + "/lite-xl/user/plugins/gitsave/native.so");
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
    
    protected String[] getArguments() {
        String[] args = new String[1];
        args[0] = getExternalFilesDir("files") + "";
        return args;
    }
    
    private void copyFile(AssetManager assetManager, String source, String target) throws IOException  {
        Log.i("assetManager", "Copying file " + source + " to " + target);
        InputStream in = assetManager.open(source);
        FileOutputStream out = new FileOutputStream(target);
        byte[] buffer = new byte[1024];
        int read;
        while((read = in.read(buffer)) != -1){
            out.write(buffer, 0, read);
        }
        in.close();
        out.flush();
        out.close();
    }    
    
    private void copyDirectoryOrFile(AssetManager assetManager, String source, String target) throws IOException {
        Log.i("assetManager", "Copying assets from " + source);
        String[] files = assetManager.list(source);
        String transformedTarget = target + "/" + source.substring(source.indexOf("/") + 1);
        if (files.length == 0) {
           copyFile(assetManager, source, transformedTarget);
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
