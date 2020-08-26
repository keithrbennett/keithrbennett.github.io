---
title: Installing International Language Keyboard Input Methods on Linux Mint 20 Cinnamon & Mate
published: true
tags: linux, mint, I18N, internationalization
canonical_url: https://blog.bbs-software.com/blog/2020/08/23/language-input-on-linux-mint-20.html
---

I just started using a desktop system using Linux Mint 20 Cinnamon, and wanted to make sure that keyboard input methods worked for Thai and Korean. This took me down a long road, consulting several blog articles, questions, and answers, so I decided to document it to save others (and future me!) this effort.

I've also briefly tested that this procedure works with Arabic, French, Hebrew, Russian, and Swedish, so I'm fairly confident that it will work for any supported language and input method.

Below are the instructions for Linux Mint Cinnamon; I believe they will be identical for Mate.


### Language Support

* Press the {Super} key, start typing `Languages`, and select the "Languages" application.
* Click "Install/Remove Languages" at the bottom right.
* If requested, enter your login password to grant superuser rights to "Languages".

For each language you want to add:

* Click "Add"
* Start typing the name of the language, select the language you want, and then click the "Install" button. 
There may not be any confirmation that it has completed.
* Find the newly installed language in the list (again, you can start to type it to find it), select it,
and click the "Install Language Packs" button.
* Confirm any confirmation dialogs as necessary.


### If...

The remainder of work to be done involves the IBus input method framework.

If at any point during this procedure, you see a dialog saying "The IBus daemon is not running. Do you wish to start it?", click "Yes".

Also, if you encounter a dialog saying "IBus has been started! If you cannot use IBus, add the following lines...", just click OK. I have seen this happen but have never needed the information displayed in the dialog.


### Install IBus

**Install the IBus keyboard input management framework and the Hangul (native Korean alphabet) support:**

`sudo apt install -y ibus-m17n ibus-hangul`


### Add IBus to the Startup Applications List
 
Press the {Super} (Windows/Mac) key, type `startup` and select "Startup Applications".

* Click the "+" button.
* Select "Custom command".
* For Name: `IBus`
* For Command: `ibus-daemon`
* Click "Add".


### Configure IBus

Press the {Super} key and type `ibus`. Select "IBus Preferences".

#### Add a keyboard shortcut

Cinnamon uses {Super}{Space} to navigate panel entries, and I have not found a way to disable that, so I assign another shortcut for language switching, {Ctrl}{Super}{Alt}-k ("k" for keyboard). Here's how:

On the "General" tab:

* click the button labelled "..." to the right of the "Next Input Method" text field
* with "{Super}<space>" selected, click the "Delete" button
* Replace any text in the "Key code" input field with "k"
* check "Control", "Alt", and "Super"
* click the "Add" button
* click the "OK" button

You may not need to do this if you are using Mate and the {Super}{Space} key combination is available for IBus to use.

Also, I found that {Ctrl}{Super}{Alt}-k _did not work_ when pressed while certain input methods were active. I briefly researched how to disable Cinnamon's use of {Super}{Space} but could not find an answer. Anyone? Assigning multiple key combinations to this action is supported, so that is another approach.

#### Add input methods

On the "Input Method" tab, click "Add".

For each desired input method, click your desired language, or if it is not listed (as with Korean and Thai), click the three vertical dots entry, click the text field to give it focus, and type the language into the text field, then select the entry below the language name that you want. In the case of Korean, there is only one ("Hangul"). Click "Add".


### Reboot and Test

Reboot the system. (If you want to save time, you could log out and then in again instead of rebooting, but that will not verify that IBus was started on system startup.)
 
Test switching input methods with {Ctrl}{Super}{Alt}-k, and typing text into an application that can accept it. 

### The Language Panel Applet

There are two methods for invoking input method selection:

* the keyboard shortcut ({Ctrl}{Super}{Alt}-k, {Super}{Space}, etc.)
* the panel applet

The panel applet is on the system panel, and will display the currently selected language. Clicking it will display a list of languages from which you can select a different one. This applet can be used as a fallback mechanism for changing language if the keyboard shortcut does not work.

Unfortunately, the text on this indicator is displayed in a dark blue text that is difficult to see against the black background, so it may take some effort to find. The Korean language setting deals with this by showing a colorful icon instead of text.


### Cautions

**Invoking Input Method Selection**

As mentioned, if the keyboard shortcut for selecting an input method does not work, remember the panel applet and use that instead.

**Know Your Input Methods**

* The Korean input method uses a {Shift}{Space} toggle key combination to toggle between Hangul and English character input. When you switch into Korean input mode from another language, it will initially be in English mode, so it may not be obvious that you have successfully switched to Korean. Press {Shift}{Space} to toggle to Hangul input mode.
* If you're new to a language, there may be things to learn about that language's computer input methods that are not taught in school or otherwise obvious. If the input does not appear to work correctly, make sure you're not overlooking a feature of that input method.
* Some languages have many input methods from which to choose, and some may be much better than others for your purposes. For example, some are Dvorak layouts of interest only to the hardiest of souls.

**Language-Specific Configuration**

There may be language specific requirements with other languages like the need to install the ibus-hangul package for Korean.

### You're done! 

Thanks for reading, and let me know in a comment on the [dev.to article page](https://dev.to/keithrbennett/installing-international-language-keyboard-input-methods-on-linux-mint-20-cinnamon-mate-3d6d) if you have any corrections or improvements to offer.
