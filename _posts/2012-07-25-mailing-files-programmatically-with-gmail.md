---
id: 536
title: Mailing Files Programmatically with GMail
date: 2012-07-25T13:06:10+00:00
author: keithrbennett
guid: http://krbtech.wordpress.com/?p=536
permalink: /index.php/2012/07/25/mailing-files-programmatically-with-gmail/
jabber_published:
  - "1343239571"
email_notification:
  - "1343239571"
categories:
  - Uncategorized
---
Recently I had the need to send someone multiple 1-2 MB files. Email was the best option, for reasons that are not very interesting, and outside the scope of this article.

I naturally turned to my favorite language, Ruby.  I did a little research into the various gems and their configuration, and offer this simple example (source code below) in the hope that it will save you a little time if you have the same need.

I&#8217;ve tried to trim out anything not relating to the actual sending of the mail so that you can more easily understand it and adapt it for your use.

&#8211; Keith

{% gist 3605940 %}
