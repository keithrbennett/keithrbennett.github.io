---
title: Automate the Little Things Too
published: true
description: Using Ruby for Primitive but Productive Workflows
tags: #ruby #shell #script
---

We developers automate highly complex tasks, but when it comes to the smaller repetitive tasks, we tend to do things manually, or fail to do them at all. By combining Ruby with robust and richly functional command line tools such as MPlayer, we can save ourselves lots of time and have fun in the process.

I recently decided that it would be nice to trim my collection of many video files downloaded from my phones over the years. Realizing this would be quite tedious, I asked myself "would this be easier with Ruby?" The answer, of course, was _Yes!_


### Integrating MPlayer and Ruby

[MPlayer](http://www.mplayerhq.hu/) is a Unix _command line_ multimedia player that can be installed with your favorite package manager (e.g. `brew`, `apt`, or `yum`). By driving MPlayer from Ruby, we can create a workflow that will enable you to view and decide about video files with a minimum of keystrokes, _without needing to use the mouse_.

Files to process are specified on the command line. Multiple arguments can be specified, either absolute or relative, and either with or without wildcards. All filespecs are normalized to their absolute form so that duplicates can be eliminated.
 
 MPlayer plays each file for the user, responding to cursor keys to move forward and backward in time, change the speed, etc. I recommend viewing the man page (`man mplayer`), but here are the most relevant options:
  
```
keyboard control
      LEFT and RIGHT
           Seek backward/forward 10 seconds.
      UP and DOWN
           Seek forward/backward 1 minute.
      PGUP and PGDWN
           Seek forward/backward 10 minutes.
      [ and ]
           Decrease/increase current playback speed by 10%.
      { and }
           Halve/double current playback speed.
      BACKSPACE
           Reset playback speed to normal.

```
  
 When the user has seen enough to make a decision, `q` or `[ESC]` can be pressed, and MPlayer returns control to the Ruby script, which accepts a one character response to mark it to be saved (`s`), deleted (`d`), or marked as undecided (`u`) for future reprocessing; or `q` to quit the application.


### The High Level View

Here is the highest level method in the script:

```ruby
def main
  check_presence_of_mplayer
  create_dirs
  puts greeting
  files_to_process.each do |filespec|
    play_file(filespec)
    print disposition_prompt(filespec)
    destination_subdir = get_disposition_from_user
    `mv #{filespec} #{destination_subdir}`
    log(filespec, destination_subdir)
  end
end
```


### Using Subdirectories

For simplicity of implementation and added safety, the application "marks" each multimedia file by moving it to one of the three subdirectories it has created, based on the user's choice. The user selects `d` for deletes, `s` for saves, or  `u` for undecideds. `create_dirs` creates the three subdirectories:

```ruby
def create_dirs
  %w{deletes  saves  undecideds}.each { |dir| FileUtils.mkdir_p(dir) }
end
```

When the user is finished processing all files, they will probably want to move any files that have been moved to `./undecided` back to `.` and run the program again.

Finally, when there are no files left in `undecided`, one will probably want to do something like this:

    rmdir undecideds
    rm -rf deletes
    mv saves/* .
    rmdir saves


### An Example

For example, let's say you run the following command:

`organize-av-files 'video/*mp4' 'audio/*mp3'`

MPlayer will begin playing the first file. When you are ready to finish viewing it, you will press `q` or `ESC`, and be presented with a prompt like this:

```
/Users/kbennett/android/video/20160102_234426.mp4:
s = save, d = delete, u = undecided, q = quit:
```
 

Type your response choice and then `[Enter]`. The program will move the file as appropriate, and immediately start playing the next file.


### Shell vs. Ruby Wildcard Expansion

Be careful when using wildcards. If you enter `*mp4` in a directory with 10,000 MP4 files, the shell will try to expand it into 10,000 arguments, which might exceed the maximum command line size and result in an error. You can instead quote the filemask (as `'*mp4'`), and it will then be passed to Ruby as a single argument, and Ruby will perform the expansion. You can usually use double quotes, but be aware that the single and double quotes behavior differs (see [this helpful StackOverflow article](https://stackoverflow.com/questions/6697753/difference-between-single-and-double-quotes-in-bash)).

One case where the shell's expansion would be preferable is with the use of environment variables in the filespec (`$FOO` is more concise than `ENV['FOO']`), and in the case of using `~` for users other than the current user (e.g. `~someoneelse`).


### Also...

* This workflow can be used with any multimedia files recognized by MPlayer, and that includes audio files.
* There are many, many nice-to-have features that have not been implemented, since speed of implementation was a high priority. Feel free to add your own!
* Although using Ruby probably enables writing the most concise and intention-revealing code, other languages such as Python would do fine as well.
* The code for this script ("organize-av-files") is currently at [https://gist.github.com/keithrbennett/4d9953e66ea35e2c52abae52650ebb1b](https://gist.github.com/keithrbennett/4d9953e66ea35e2c52abae52650ebb1b).



### Conclusion

I hope you can see that with a modest amount of code you can build a highly useful (albeit not fancy) automation tool. The amount of expected use and the benefit per use determines the optimum amount of effort, and you have the freedom to choose any point in that continuum. The notion that all applications need to be feature-rich is not a useful one, and often results in inaction altogether.
 
 Ruby is a great tool for this sort of thing. Why not use it?
 
 --- The End ---
 
 ----
 


[Note: This article is occasionally improved. Its commit history is [here](https://github.com/keithrbennett/keithrbennett.github.io/commits/master/blog/_posts/2019-09-24-automate-the-little-things-too.md).]
 
 ----
 
 For your convenience, the script is displayed below:
 
 ```ruby
#!/usr/bin/env ruby

# organize-av-files - Organizes files playable by mplayer
# into 'saves', 'deletes', and 'undecideds' subdirectories.
#
# stored at:
# https://gist.github.com/keithrbennett/4d9953e66ea35e2c52abae52650ebb1b


require 'date'
require 'fileutils'
require 'set'

LOG_FILESPEC = 'organize-av-files.log'

def create_dirs
  %w{deletes  saves  undecideds}.each { |dir| FileUtils.mkdir_p(dir) }
end


def check_presence_of_mplayer
  if `which mplayer`.chomp.size == 0
    raise "mplayer not detected. "
        "Please install it (with apt, brew, yum, etc.)"
  end
end


# Takes all ARGV elements, expands any wildcards,
# converts to normalized (absolute) form,
# and eliminates duplicates.
def files_to_process

  # Dir[] does not understand ~, need to process it ourselves.
  # This does *not* handle the `~username` form.
  replace_tilde_if_needed = ->(filespec) do
    filespec.start_with?('~/')                    \
        ? File.join(ENV['HOME'], filespec[2, -1]) \
        : filespec
  end

  # When Dir[] gets a directory it returns no files.
  # Need to add '/*' to it.
  add_star_to_dirspec_if_needed = ->(filespec) do
    File.directory?(filespec)      \
        ? File.join(filespec, '*') \
        : filespec
  end

  # Default to all nonhidden files in current directory
  # but not its subdirectories.
  ARGV[0] ||= '*'

  all_filespecs = ARGV.each_with_object(Set.new) do |filemask, all_filespecs|
    filemask = replace_tilde_if_needed.(filemask)
    filemask = add_star_to_dirspec_if_needed.(filemask)

    Dir[filemask]                          \
        .map { |f| File.absolute_path(f) } \
        .select { |f| File.file?(f) }      \
        .each do |filespec|
      all_filespecs << filespec
    end
  end
  all_filespecs.sort
end


def greeting
  puts <<~GREETING
      organize-av-files

      Enables the vetting of audio and video files. 

      For each file, plays it with mplayer, and prompts for what you would like to do 
      with that file, moving the file to one of the following subdirectories:

      * deletes
      * saves
      * undecideds

      This software uses mplayer to play audio files. Use cursor keys to move forwards/backwards in time.
      Press 'q' or 'ESC' to abort playback and specify disposition of that file.

      Run `man mplayer` for more on mplayer.

      Assumes all files specified are playable by mplayer.
      Creates subdirectories in the current directory: deletes, saves, undecideds.
      Logs to file '#{LOG_FILESPEC}'

  GREETING
end


def play_file(filespec)
  # If you have mplayer problems, remove the redirection ("2> /dev/null")
  # to see any errors.
  `mplayer #{filespec} 2> /dev/null`
end


def disposition_prompt(filespec)
  "\n\n#{filespec}:\ns = save, d = delete, u = undecided, q = quit: "
end


def get_disposition_from_user
  loop do
    response = $stdin.gets.chomp.downcase

    if response == 'q'
      exit
    elsif %w(s d u).include?(response)
      return {
          's' => 'saves',
          'd' => 'deletes',
          'u' => 'undecideds'
      }[response]
    else
      print "s = save, d = delete, u = undecided, q = quit: "
    end
  end
end


def log(filespec, destination_subdir)
  dest_abbrev = destination_subdir[0].upcase # 'S' for saves, etc.
  log_message = "#{dest_abbrev}  #{Time.now}  #{filespec}"
  `echo #{log_message} >> #{LOG_FILESPEC}`
end


def main
  check_presence_of_mplayer
  create_dirs
  puts greeting
  files_to_process.each do |filespec|
    play_file(filespec)
    print disposition_prompt(filespec)
    destination_subdir = get_disposition_from_user
    `mv #{filespec} #{destination_subdir}`
    log(filespec, destination_subdir)
  end
end


main
```