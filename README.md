# write-xl

write-xl is a set of plugins that operates overtop of lite-xl. It's designed to make the text editor more appealing to use for writing and reading fiction, in markdown.

## Features

* A more word-like **color** scheme.
* An automatic configuration of line wrapping and document setup to be more word-like.
* Keybinds for standard stuff like bolding, italicizing, and underlining (`ctrl`+`b`, `ctrl`+`i`, `ctrl`+`u`).
* Spellchecker
* Synonyms
* Jump to Chapter
* Ability use git quicly and easily to track changes, and to provide a method of remote synchroniation.
* Word Counter
* Small clock in the bottom right corner.

## Building

1. `source android/env.sh`
2. `cd android/com.litexl.writexl`
3. `./gradlew installDebug`

## Android Notes

Things I had to do to get this godawful monstrosity working:

1. Not much for base lite. Had to patch in LITE_PREFIX into start code, and to start.lua. Had to patch in `SDL_EventState(SDL_, SDL_ENABLED);` and a small bit into
	 core.set_active_view: `if view:is(DocView) then system.start_editing() else system.end_editing() end`, and those two system functions.
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
  * update the compiler standard to C99 in libgit2 (`C_STANDARD`).
3. Ensure that openssl is clean each time, and that it's on 1.1.1 stable; master has relocation errors in ARM64.
4. When we throw in dynamic plugins into android, they need to be linked and packed in a particular way. You can't just dlopen something anymore;
   It has to be done through a particular packing method.

## TODO

* Chapter Navigation, via sicebar.
* Chapter wordcount in parentheses on sidebar.
* Automatic Chapter Summaries as a view, by running chapter through an automatic summarizer library.
* Side-by-Side Outline Reading
* A plugin to detect whether you're overusing a particular phrase.
* Character Registry, with Minimap
* Small clock that tracks current session time.
* Small clcok that tracks actual writing time.
* Ability to have a view of a chapter as an individual document (`ChapterView`, inherited from DocView).
*

## Install

To install, simply use [`lpm`](https://github.com/lite-xl/lite-xl-plugin-manager):

```
lpm run write-xl
```

As an alternative, set this directory as your `LITE_USERDIR` environment variable.

## Useful Commands

* `adb shell runas com.litexl.writexl sh`
