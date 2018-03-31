---
id: 197
title: 'GPartEd &#8211; Free and Open Source Disk Partitioner'
date: 2009-07-01T13:18:50+00:00
author: keithrbennett
layout: post
guid: http://krbtech.wordpress.com/?p=197
permalink: /index.php/2009/07/01/gparted-free-and-open-source-disk-partitioner/
categories:
  - Uncategorized
tags:
  - gnome
  - gparted
  - partition editor
  - partition magic
---
![GPartEd Main Window](http://gparted.sourceforge.net/screens/gparted_1_big.png)

GPartEd (<http://gparted.sourceforge.net>) is a free and open source software tool that does disk partitioning like its commercial counterpart, PartitionMagic. Although GPartEd is cursed with a boring name, it is nevertheless a superstar product with both looks _and_ brains. (For the looks, see <http://gparted.sourceforge.net/screenshots.php>.) The name _GPartEd_ is an abbreviation for Gnome Partition Editor.

Although I have not done any thorough or systematic comparison of GPartEd and PartitionMagic, I _can_ say that I have successfully used GPartEd for some nontrivial partition schemes, and it worked beautifully.

GPartEd runs natively on Linux, but if you are using other operating systems such as Windows or OS X, you can put it on a bootable medium such as a CD or USB drive and boot from that medium. More information on this is at <http://gparted.sourceforge.net/livecd.php>.

<!--more-->

When the bootable medium starts up, it boots Linux, but you don&#8217;t need to care about that &#8212; it&#8217;s got an attractive and intuitive GUI. It&#8217;s aware of a multitude of partition types, including types used by Windows, OS X, Linux, and Solaris, so it&#8217;s not likely that the one you want will be missing. You can see all the supported partition types at <http://gparted.sourceforge.net/features.php>.

### Using GPartEd to Add an Operating System to Your Drive

My recent need for GPartEd was to add Linux to a Windows laptop. The result is that I&#8217;m writing this on that laptop, running Ubuntu Linux 9.04. The laptop&#8217;s hard drive came with a single huge Windows partition and a small recovery partition. Using GPartEd, I shrunk the Windows partition and created several ext4 and swap partitions for the Linux install.

The Ubuntu installation writes the Grub boot loader to the boot sector of your drive. When your system starts up, Grub presents a menu, and you can select which operating system you would like to boot.

Although I used it to have Linux and Windows share the same drive, you could have any combination of operating systems. This could be a way to try out a new OS (e.g. Windows 7 or a new Linux distro) without totally committing to it. Since Macs are now Intel based, GPartEd should work fine on a Mac, and you could boot OS X, Linux, or Windows from different partitions on the same drive. The only caveat is that you need to install a boot loader to enable you to select which OS to load when the system boots up. Most Linux installations will do this for you automatically.

Another handy use of GPartEd is to create a partition for data that can be shared by multiple OS&#8217;s on the drive. For example, you may have documents, photos, and/or music files that you want to access regardless of which OS you boot. All you need to do is to create the partition in a format recognized by all the OS&#8217;s on your system. I use fat32 for this. 

GPartEd is just one of a multitude of free open source software products that can make our technical lives easier &#8212; and cheaper. Kudos to the developers and other contributors that made it possible.

Feel free to comment with any feedback or experiences.

&#8211; Keith