# BrightKeyMap

## What is it? ##

An AutoHotkey-powered installer for Windows that configures which keys you want to press to adjust brightness, volume, and media (Play/Pause, Next track, Previous track).

## How to Use ##

Run the installer each time you want to re-map your keys. For function keys, just type "F" followed by the number (e.g., "F12"). You can reference [this list](https://gist.github.com/csharpforevermore/11348986) of special keys if needed.

## How Does it Work/How to Edit? ##

A Windows Task is scheduled that runs `BrightKeyMap.exe` on logon of any user, which is a compiled executable of an `.ahk` AutoHotkey script. You can download and edit the `.ahk` from the repo.

## Troubleshoot ##

Install your latest hardware drivers. 
Make sure your hardware actually supports OS-level brightness adjustments. (If you have a desktop monitor, you probably need to adjust brightness using the physical buttons.)
Make sure you configured the Keys correctly during setup. Reference [this list](https://gist.github.com/csharpforevermore/11348986)) and make sure you did not duplicate mapped keys (i.e., Don't map "F2" to "Volume Up" and "Play/Pause" for example).

## Requests ##

If this is potentially useful to anyone out there, I assume there&#39;s modifications and incompatibilities people would like tweaked, so email me or create GitHub Issues, or download the AutoHotkey script from the repo and edit it yourself.

2021 Wade Murdock

[https://wadestechtrove.blogspot.com/](https://wadestechtrove.blogspot.com/)

wad11656@gmail.com

*(Credit: qwerty12's LaptopBrightnessSetter)*
