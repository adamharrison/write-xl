# write-xl

`write-xl` is a set of plugins that operates overtop of lite-xl. It's designed to make the text editor more appealing to use for writing and reading fiction, in markdown.

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

## TODO

* Chapter Navigation, via sidebar.
* Chapter wordcount in parentheses on sidebar.
* Automatic Chapter Summaries as a view, by running chapter through an automatic summarizer library.
* Side-by-Side Outline Reading
* A plugin to detect whether you're overusing a particular phrase.
* Character Registry, with Minimap
* Small clock that tracks current session time.
* Small clcok that tracks actual writing time.
* Ability to have a view of a chapter as an individual document (`ChapterView`, inherited from DocView).

## Install

To install, simply use [`lpm`](https://github.com/lite-xl/lite-xl-plugin-manager):

```
lpm install write-xl
```

Or, alternatively, simply copy the plugins in the `plugins` folder, and the colors from the `colors` folder into your local copies of both, and install a few extra plugins from lite-xl-plugins.

Or, you can simply pull an all-in-one-release from the [releases](https://github.com/adamharrison/write-xl/releases) page.
