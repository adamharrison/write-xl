# WRITE-XL

Write-XL is a set of plugins that operates overtop of lite-xl. It's designed to make the text editor more appealing to use for writing and reading fiction, in markdown.

## Features

* A more word-like **color** scheme.
* An automatic configuration of line wrapping and document setup to be more word-like.
* Keybinds for standard stuff like bolding, italicizing, and underlining (`ctrl`+`b`, `ctrl`+`i`, `ctrl`+`u`).
* Spellchecker
* Synonyms
* Jump to Chapter

## Building

1. `source android/env.sh`
2. `cd android/com.litexl.writexl`
3. `./gradlew installDebug`

## Android Notes

Things I had to do to get this godawful monstrosity working:

1. Not much for base lite.
2. For libgit2, I had to:
  * Patch in getloadavg into the build; specifically into the bottom of src/rand.c.
  
  ```c
    #include <sys/sysinfo.h>
    
    int getloadavg(double averages[], int n) {
      if (n < 0) return -1;
      if (n > 3) n = 3;
      struct sysinfo si;
      if (sysinfo(&si) == -1) return -1;
      for (int i = 0; i < n; ++i) {
        averages[i] = (double)(si.loads[i]) / (double)(1 << SI_LOAD_SHIFT);
      }
      return n;
    }
  ```
3. Ensure that openssl is clean each time, and that it's on 1.1.1 stable; master has relocation errors in ARM64.

## TODO

	Specifically, I want to have git as an executable the APK can access, and use. This would allow basic pushing/pulling/cloning through a github repo to save files.
	It looks like it's gonna be complex to support `ssh` authentication. So unless you have `ssh` installed on your phone, we're going to only support https.
* Chapter Navigation
* Automatic Chapter Summaries
* Side-by-Side Outline Reading
* Using `git` as a track changes method (because, let's be real, track changes is shit, normally; and `git` is one of the most used softwares on the planet).
* A plugin to detect whether you're overusing a particular phrase.
* Character Registry, with Minimap
* Word Count
* Other Document Metrics

## Install
 
To install, simply drop the `user` folder next to your `lite-xl` executable, or, set your `XDG_CONFIG_HOME` environment variable to this repository's directory.
