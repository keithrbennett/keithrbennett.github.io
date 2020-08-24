---
title: Installing International Language Keyboard Input Methods on Linux Mint 20 Cinnamon & Mate
published: true
tags: linux, mint, cinnamon, I18N, internationalization
canonical_url: https://blog.bbs-software.com/blog/2020/08/23/language-input-on-linux-mint-20.html
---

I just started using a desktop system using Linux Mint 20 Cinnamon, and wanted to make sure that keyboard input methods worked for Thai and Korean. This took me down a long road, consulting several blog articles, questions, and answers, so I decided to document it to save others (and future me!) this effort.

I've also briefly tested that this procedure works with Arabic, French, Hebrew, Russian, and Swedish, so I'm fairly confident that it will work for any supported language and input method.

Below are the instructions for Linux Mint Cinnamon; I believe they will be identical for Mate.


### Install IBus

**Install the IBus keyboard input management framework and the Hangul (native Korean alphabet) support:**

`sudo apt install -y ibus-m17n ibus-hangul`

##### Configure the IBus daemon to start up automatically on system startup:
 
Press the {Super} (Windows/Mac) key, type `startup` and select "Startup Applications".

* Click the "+" button.
* Select "Custom command".
* For Name: `IBus Daemon`
* For Command: `ibus-daemon`
* Click "Add".


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

Reboot the system when all your desired languages have been installed.


### Configure iBus

Press the {Super} key and type `ibus`. Select "iBus Preferences". If you see a dialog saying "The iBus daemon is not running. Do you wish to start it?", click "Yes".

You may see a dialog saying "IBus has been started! If you cannot use IBus, add the following lines...". I have not needed to do the extra step described here, so I just click OK wihtout saving the information anywhere.


#### Add a keyboard shortcut

Cinnamon uses {Super}{Space} to navigate panel entries, and I have not found a way to disable that, so I assign another shortcut for language switching, {Ctrl}{Super}{Alt}-i. Here's how:

On the "General" tab:

* click the button labelled "..." to the right of the "Next Input Method" text field
* with "{Super}<space>" selected, click the "Delete" button
* Replace any text in the "Key code" input field with "i"
* check "Control", "Alt", and "Super"
* click the "Add" button
* click the "OK" button

You may not need to do this if you are using Mate and the {Super}{Space} key combination is available for IBus to use.

Also, I found that {Ctrl}{Super}{Alt}-i _did not work_ when pressed while certain input methods were active. I briefly researched how to disable Cinnamon's use of {Super}{Space} but could not find an answer. Anyone? Assigning multiple key combinations to this action is supported, so that is another approach.

#### Add input methods

On the "Input Method" tab, click "Add".

For each desired input method, click your desired language, or if it is not listed (as with Korean and Thai), click the three vertical dots entry, click the text field to give it focus, and type the language into the text field, then select the entry below the language name that you want. In the case of Korean, there is only one ("Hangul"). Click "Add".

### Cautions

**Invoking Input Method Selection**

There are two methods for invoking input method selection:

* the keyboard shortcut ({Ctrl}{Super}{Alt}-i, {Super}{Space}, etc.)
* the panel applet

Beware, the keyboard shortcut may not work with some input methods (as previously mentioned), and the panel applet is barely visible due to its tiny size and dark blue color that's very difficult to see against the panel's dark background. 

**Know Your Input Methods**

* The Korean input method uses a {Shift}{Space} toggle key combination to toggle between Hangul and English character input. When you switch into Korean input mode from another language, it will initially be in English mode, so it may not be obvious that you have successfully switched to Korean. Press {Shift}{Space} to toggle to Hangul input mode.
* If you're new to a language, there may be things to learn about that language's computer input methods that are not taught in school or otherwise obvious. If the input does not appear to work correctly, make sure you're not overlooking a feature of that input method.
* Some languages have many input methods from which to choose, and some may be much better than others for your purposes. For example, some are Dvorak layouts of interest only to the hardiest of souls.

**Language-Specific Configuration**

There may be language specific requirements with other languages like the need to install the ibus-hangul package for Korean.

### You're done! 

Thanks for reading, and let me know if you have any corrections or improvements to offer.
