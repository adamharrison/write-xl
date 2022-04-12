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
import java.io.File;

public class writexlActivity extends SDLActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        try {
            copyDirectoryOrFile(getAssets(), "data");
        } catch (IOException e) {
            Log.e("assetManager", "Failed to copy assets: " + e.getMessage());
        }
        super.onCreate(savedInstanceState);
        String prefix = getExternalFilesDir(null) + "";
        Log.i("litexl", "Setting LITE_PREFIX to " + prefix);
        nativeSetenv("LITE_PREFIX", prefix);
        Log.i("litexl", "Setting HOME to " + prefix);
        nativeSetenv("HOME", prefix);
        Log.i("litexl", "Setting LITE_SCALE to 1.0");
        nativeSetenv("LITE_SCALE", "1.0");
        String userdir = prefix + "/user";
        File directory = new File(userdir);
        if (!directory.exists() && !directory.mkdir())
            Log.e("assetManager", "Can't make directory " + userdir);
        Log.i("litexl", "Setting XDG_CONFIG_HOME to " + userdir);
        nativeSetenv("XDG_CONFIG_HOME", userdir);
    }
    
    private void copyDirectoryOrFile(AssetManager assetManager, String path) throws IOException {
        Log.i("assetManager", "Copying assets from " + path);
        String[] files = assetManager.list(path);
        String target = getExternalFilesDir("share") + "/lite-xl/" + path.replace("data/", "");
        if (files.length == 0) {
            Log.i("assetManager", "Copying file " + path + " to " + target);
            InputStream in = assetManager.open(path);
            FileOutputStream out = new FileOutputStream(target);
            byte[] buffer = new byte[1024];
            int read;
            while((read = in.read(buffer)) != -1){
                out.write(buffer, 0, read);
            }
            in.close();
            out.flush();
            out.close();
        } else {
            Log.i("assetManager", "Copying directory " + path + " to " + target);
            File directory = new File(target);
            if (!directory.exists() && !directory.mkdir())
                throw new IOException("Can't make directory " + target);
            for (String file : files)
                copyDirectoryOrFile(assetManager, path != "" ? path + "/" + file : file);
        }
    }
}
