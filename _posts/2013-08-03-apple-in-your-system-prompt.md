---
id: 1320
title:  in Your System Prompt
date: 2013-08-03T21:08:34+00:00
author: keithrbennett
guid: http://www.bbs-software.com/blog/?p=1320
permalink: '/index.php/2013/08/03/%ef%a3%bf-in-your-system-prompt/'
categories:
  - Uncategorized
---
In my daily work, I often connect to Linux boxes from my Mac. With several terminal windows open, it&#8217;s nice to easily see which ones are connected to my local Mac, and which ones are connected to other machines. One can certainly insert the host name into the system prompt. Here&#8217;s an example that contains the time, host name, and current directory:

```
>export PS1="\n\t \h:\w\n&gt; "

21:02:45 my_host_name:~
>
```

Wait a minute, I thought, I wonder if there&#8217;s a Unicode character that can be included in the prompt that will jump out at me to tell me where I am&#8230;so I searched the web, and on [http://hea-www.harvard.edu/~fine/OSX/unicode\_apple\_logo.html](http://hea-www.harvard.edu/~fine/OSX/unicode_apple_logo.html "http://hea-www.harvard.edu/~fine/OSX/unicode_apple_logo.html") was the apple logo!

So I now have the Apple logo as the very first character of my system prompt. A picture grabs the eye more effectively than a letter, so it&#8217;s much easier now to tell that this terminal is connected to my Mac:

```
>export PS1="\n \t \h:\w\n> "
 
 21:00:50 my_host_name:~
> ```
