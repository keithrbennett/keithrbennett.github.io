---
title: Automate the Little Things Too
published: true
description: Using Ruby for Primitive but Productive Workflows
tags: #ruby #shell #script
---

We developers automate highly complex tasks, but when it comes to the smaller repetitive tasks, we tend to do things manually, or fail to do them at all. By combining Ruby with command line tools such as MPlayer, we can save ourselves lots of time and have fun in the process.

I recently decided that it would be nice to trim my collection of many video files downloaded from my phones over the years. Realizing this would be quite tedious, I asked myself "would this be easier with Ruby?"

### Integrating MPlayer and Ruby

[MPlayer](http://www.mplayerhq.hu/) is a Unix _command line_ multimedia player that can be installed with your favorite package manager (brew/apt/yum). By driving it from Ruby, we can create a tool that will enable you to view and decide about video files with a minimum of keystrokes, _and no need to use the mouse_.

Files to view are specified on the command line. For each file, MPlayer presents it to the user, responding to cursor keys to move forward and backward. When the user has seen enough to make a decision, `q` can be pressed, and MPlayer returns control to the Ruby script. The Ruby script accepts a one character response to save, delete, or do neither.

There are many, many nice-to-have features that have not been implemented, since speed of implementation was a high priority. Feel free to add your own!

### The High Level View

Here is the highest level method in the script:

```ruby
def main
  check_presence_of_mplayer
  create_dirs
  puts greeting
  files_to_process.each do |filespec|
    puts "\n\nPlaying #{filespec}..\n\n"
    play_file(filespec)
    print disposition_prompt(filespec)
    destination_subdir = get_disposition_from_user
    `mv #{filespec} #{destination_subdir}`
    log(filespec, destination_subdir)
  end
end
```

### Using Subdirectories
You may notice that the file is moved to a subdirectory specified by the user. `create_dirs` creates three subdirectories:

```ruby
def create_dirs
  %w{deletes  saves  undecideds}.each { |dir| FileUtils.mkdir_p(dir) }
end
```

This workflow is not completely automated. Files marked for deletion are only moved to a subdirectory named `deletes`. This gives an added level of protection. When done, it's a simple matter to execute a `rm -rf deletes`.

For files that may require further research, one can send them to the `undecideds` directory. This defers the decision and excludes the file from a future search of the same input directory.

Files 