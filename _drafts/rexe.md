---
title: The `rexe` Command Line Executor and Filter
date: 2019-02-15
---

I love the power of the command line, but not the awkwardness of shell scripting languages. Sure, there's a lot that can be done with them, but it doesn't take long before I get frustrated with their bluntness and verbosity.

Often, I solve this problem by writing a Ruby script instead. Ruby gives me fine grained control in a "real" programming language with which I am comfortable. However, when there are multiple OS commands to be called, then Ruby can be awkward too.

Sometimes a good solution is to combine Ruby and shell scripting on the same command line. Here's an example, using an intermediate environment variable to simplify the logic (an excerpt of the color output follows the code):

```
export JSON_TEXT=`curl https://api.exchangeratesapi.io/latest`
echo $JSON_TEXT | ruby -r json -r awesome_print -e 'ap JSON.parse(STDIN.read)'
```

![output of ap](2019-02-15-shot-1.png)

However, the length and verbosity of the command are awkward and discourage this approach.

Enter, the `rexe` script (coincidentally, written by me!). `rexe` is at https://github.com/keithrbennett/rexe and can be installed with `gem install rexe`. `rexe` provides several ways to simplify Ruby on the command line, tipping the scale so that it can be done more often.

For consistency with the `ruby` interpreter we called previously, `rexe` supports requires with the `-r` option, but also allows grouping them together using commas:

```
echo $JSON_TEXT | rexe -r json,awesome_print 'ap JSON.parse(STDIN.read)'
```

This command produces the same results as the previous one.

Using any of several configuration approaches, the `json` and `awesome_print` requires can be excluded from the command line altogether so that the command is shortened and simplified. One way is to use the `REXE_OPTIONS` environment variable:

```
export REXE_OPTIONS="-r json,awesome_print"
echo $JSON_TEXT | rexe 'ap JSON.parse(STDIN.read)'
```

Like any environment variable, it could also be set in your startup script, input on the command line, or in another script loaded with `source` or `.`.

This approach works well for command line options, but what if we want to run Ruby code that can be used by all invocations of `rexe`? An example would be if we want to write methods that would be available to us on the command line.

For this, `rexe` lets you _load_ Ruby files, using the `-l` or `-u` options, or implicitly (without your specifying it) in the case of the `~/.rexerc` file. Here is an example of something you might include in such a file (this is an alternate approach to specifying `-r` in the `REXE_OPTIONS` environment variable):

```
require 'json'
require 'yaml'
require 'awesome_print'
```

Requiring gems and modules from a configuration file instead of on a command line will make your commands simpler and more concise. However, this will be a waste of time if they are not needed. You can inspect the execution times to see just how much time is being wasted. For example, we can find out that nokogiri takes about 0.8 seconds to load on my laptop by observing the execution time with and without the require:

```
➜  ~   rexe -v
rexe version 0.6.0 -- 2019-02-23 16:51:48 +0700
Source Code:
Options: {:input_mode=>:no_input, :loads=>[], :requires=>[], :verbose=>true}
Loading global config file /Users/kbennett/.rexerc
rexe time elapsed: 0.094946 seconds.
➜  ~   rexe -v -r nokogiri
rexe version 0.6.0 -- 2019-02-23 16:51:53 +0700
Source Code:
Options: {:input_mode=>:no_input, :loads=>[], :requires=>["nokogiri"], :verbose=>true}
Loading global config file /Users/kbennett/.rexerc
rexe time elapsed: 0.165996 seconds.
```

Here's something else you could include in such a load file:

```
# Open YouTube to Wagner's "Ride of the Valkyries"
def valkyries
  `open "http://www.youtube.com/watch?v=P73Z6291Pt8&t=0m28s"`
end
```

Why would you want this? You might want to be able to go to another room until a long job completes, and be notified when it is done. The `valkyries` method will launch a browser window pointed to Richard Wagner's "Ride of the Valkyries" starting at a lively point in the music. (The `open` command is Mac specific and could be replaced with `start` on Windows, a browser command name, etc.) If you like this sort of thing, you could download public domain audio files and use a command like player like `afplay` on Mac OS, or `mpg123` or `ogg123` on Linux. This is lighter weight, requires no network access, and will not leave an open browser window for you to close.

Defining methods in your loaded files enables you to effectively define a DSL for your command line use.

Here is an example of how you might use this, assuming the above configuration is in your ~/.rexerc file (or otherwise loaded):

```
tar czf /tmp/my-whole-user-space.tar.gz ~ ; rexe valkyries
```

If you ever want to see how `rexe` has been configured by all these approaches, you can make use of its _verbose mode_ by specifying the `-v` option. If we were to add the `-v` option to the previous command, we would see these additional lines in the output:
 
```
rexe version 0.5.0 -- 2019-02-19 19:18:48 +0700
Source Code: ap JSON.parse(STDIN.read)
Options: {:input_mode=>:no_input, :loads=>[], :requires=>["json", "awesome_print"], :verbose=>true}
Loading global config file /Users/kbennett/.rexerc
...
rexe time elapsed: 0.051131 seconds.
``` 
 
This extra output is sent to standard error (_stderr_) instead of standard output (_stdout_) so that it will not pollute the "real" data when stdout is piped to another command.)



```

Using this approach we could eliminate the requires by creating a `~/.rbrc` file containing:

```
require 'json'
require 'awesome_print'
``` 

Then we could invoke Ruby this way:

```
echo JSON_TEXT | rb $RB_COMMAND
```


$.>1 is extraneous in this and next one:

ruby -ane 'puts $F[0] if $F[1].to_i > 35 && $.>1' fruits.txt

Show disk space used/free:

`df -h | rb "x = self.grep(/disk1s1/).first.split; puts %Q{#{x[4]} Used: #{x[2]}, Avail #{x[3]}}"`


Print yellow:

`cowsay hello | rb "print %Q{\u001b[33m}; puts self.to_a.join"`


Add line numbers:

`ls | rb "self.each_with_index { |ln,i| puts '%5d  %s' % [i, ln] }"`
`ls | rb "self.each { |line| puts '%5d  %s' % [$., line] }"`


Add date/time:

ls -l | rb -l "require 'date'; print DateTime.now.iso8601 + ' : ' + self"
