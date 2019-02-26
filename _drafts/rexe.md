---
title: The `rexe` Command Line Executor and Filter
date: 2019-02-15
---

I love the power of the command line, but not the awkwardness of shell scripting languages. Sure, there's a lot that can be done with them, but it doesn't take long before I get frustrated with their bluntness and verbosity.

Often, I solve this problem by writing a Ruby script instead. Ruby gives me fine grained control in a "real" programming language with which I am comfortable. However, when there are multiple OS commands to be called, then Ruby can be awkward too.

### Using the Ruby Interpreter on the Command Line

Sometimes a good solution is to combine Ruby and shell scripting on the same command line. Here's an example, using an intermediate environment variable to simplify the logic (an excerpt of the output follows the code):

```
➜  ~   export JSON_TEXT=`curl https://api.exchangeratesapi.io/latest`
➜  ~   echo $JSON_TEXT | ruby -r json -r awesome_print -e 'ap JSON.parse(STDIN.read)'
{
    "rates" => {
        "MXN" => 21.781,
        ...
        "DKK" => 7.462
    },
     "base" => "EUR",
     "date" => "2019-02-22"
}
```

However, the length and verbosity of the command are awkward and discourage this approach.

### Rexe

Enter, the `rexe` script (coincidentally, written by me!). `rexe` is at https://github.com/keithrbennett/rexe and can be installed with `gem install rexe`. `rexe` provides several ways to simplify Ruby on the command line, tipping the scale so that it is practical to do it more often.

Here is `rexe`'s help text:

```
rexe -- Ruby Command Line Filter/Executor -- v0.6.1 -- https://github.com/keithrbennett/rexe

Executes Ruby code on the command line, optionally taking standard input and writing to standard output.

Options:

-h, --help                 Print help and exit
-l, --load RUBY_FILE(S)    Ruby file(s) to load, comma separated, or ! to clear
-u, --load-up RUBY_FILE(S) Ruby file(s) to load, searching up tree, comma separated, or ! to clear
-m, --mode MODE            Mode with which to handle input (i.e. what `self` will be in the code):
                           -ms for each line to be handled separately as a string
                           -me for an enumerator of lines (least memory consumption for big data)
                           -mb for 1 big string (all lines combined into single multiline string)
                           -mn to execute the specified Ruby code on no input at all (default)
-r, --require REQUIRES     Gems and built-in libraries to require, comma separated, or ! to clear
-v, --[no-]verbose         verbose mode (logs to stderr); to disable, short options: -v n, -v false

If there is an .rexerc file in your home directory, it will be run as Ruby code
before processing the input.

If there is a REXE_OPTIONS environment variable, its content will be prepended to the command line
so that you can specify options implicitly (e.g. `export REXE_OPTIONS="-r awesome_print,yaml"`)
```

For consistency with the `ruby` interpreter we called previously, `rexe` supports requires with the `-r` option, but also allows grouping them together using commas:

```
echo $JSON_TEXT | rexe -r json,awesome_print 'ap JSON.parse(STDIN.read)'
```

This command produces the same results as the previous `ruby` one.

### Simplifying the Rexe Invocation with Configuration

Using any of several configuration approaches, the `json` and `awesome_print` requires can be excluded from the command line altogether so that the command is shortened and simplified. 

#### The REXE_OPTIONS Environment Variable

One way is to use the `REXE_OPTIONS` environment variable:

```
export REXE_OPTIONS="-r json,awesome_print"
echo $JSON_TEXT | rexe 'ap JSON.parse(STDIN.read)'
```

Like any environment variable, `REXE_OPTIONS` could also be set in your startup script, input on a command line using `export`, or in another script loaded with `source` or `.`.

#### Loading Files

This approach works well for command line _options_, but what if we want to specify Ruby _code_ (e.g. methods) that can be used by all invocations of `rexe`?

For this, `rexe` lets you _load_ Ruby files, using the `-l` or `-u` options, or implicitly (without your specifying it) in the case of the `~/.rexerc` file. Here is an example of something you might include in such a file (this is an alternate approach to specifying `-r` in the `REXE_OPTIONS` environment variable):

```
require 'json'
require 'yaml'
require 'awesome_print'
```

Requiring gems and modules for _all_ invocations of `rexe` will make your commands simpler and more concise, but will be a waste of execution time if they are not needed. You can inspect the execution times to see just how much time is being wasted. For example, we can find out that nokogiri takes about 0.8 seconds to load on my laptop by observing and comparing the execution times with and without the require:

```
➜  ~   rexe -v
rexe version 0.6.0 -- 2019-02-23 16:51:48 +0700
Source Code:
Options: {:input_mode=>:no_input, :loads=>[], :requires=>[], :verbose=>true}
Loading global config file /Users/kbennett/.rexerc
rexe time elapsed: 0.094946 seconds.   # <---------------------------

➜  ~   rexe -v -r nokogiri
rexe version 0.6.0 -- 2019-02-23 16:51:53 +0700
Source Code:
Options: {:input_mode=>:no_input, :loads=>[], :requires=>["nokogiri"], :verbose=>true}
Loading global config file /Users/kbennett/.rexerc
rexe time elapsed: 0.165996 seconds.   # <---------------------------
```

### Using Loaded Files in Your Commands

Here's something else you could include in such a load file:

```
# Open YouTube to Wagner's "Ride of the Valkyries"
def valkyries
  `open "http://www.youtube.com/watch?v=P73Z6291Pt8&t=0m28s"`
end
```

Why would you want this? You might want to be able to go to another room until a long job completes, and be notified when it is done. The `valkyries` method will launch a browser window pointed to Richard Wagner's "Ride of the Valkyries" starting at a lively point in the music. (The `open` command is Mac specific and could be replaced with `start` on Windows, a browser command name, etc.) If you like this sort of thing, you could download public domain audio files and use a command like player like `afplay` on Mac OS, or `mpg123` or `ogg123` on Linux. This approach is lighter weight, requires no network access, and will not leave an open browser window for you to close.

Here is an example of how you might use this, assuming the above configuration is loaded from your `~/.rexerc` file or 
an explicitly loaded file:

```
tar czf /tmp/my-whole-user-space.tar.gz ~ ; rexe valkyries
```

You might be thinking that creating an alias or a minimal shell script for this open would be a simpler and more natural
approach, and I would agree with you. However, over time the number of these could become unmanageable, and using Ruby
you could build a pretty extensive and well organized library of functionality.

Defining methods in your loaded files enables you to effectively define a DSL for your command line use. You could use different load files for different projects, domains, or contexts, and define aliases or one line scripts to give them meaningful names. For example, if I wrote code to work with Ansible and put it in `~/projects/rexe-ansible.rb`, I could define an alias in my startup script:

```
alias rxans="rexe -l ~/projects/rexe-ansible.rb $*"
```
...and then I would have an Ansible DSL available for me to use with `rxans`.

There may be times when you have specified a load or require in the configuration
(environment variable, ~/.rexerc, etc.), but you want to override it for a
single invocation. Currently you cannot unspecify a single resource, but you
can unspecify _all_ the requires or loads with the `-r!` and `-l!` command line
options, respectively.



#### Verbose Mode

In addition to displaying the execution time, verbose mode will display the version, date/time of execution, source code
to be evaluated, options specified (by all approaches), and that the global file has been loaded (if it was found):
 
```
➜  ~   rexe -rjson,awesome_print "ap JSON.parse(STDIN.read)"
rexe version 0.5.0 -- 2019-02-19 19:18:48 +0700
Source Code: ap JSON.parse(STDIN.read)
Options: {:input_mode=>:no_input, :loads=>[], :requires=>["json", "awesome_print"], :verbose=>true}
Loading global config file /Users/kbennett/.rexerc
...
rexe time elapsed: 0.051131 seconds.
``` 
 
This extra output is sent to standard error (_stderr_) instead of standard output
(_stdout_) so that it will not pollute the "real" data when stdout is piped to
another command.

If verbose mode is enabled in configuration and you want to disable it, you can
do so by using any of the following: `--[no-]verbose`, `-v n`, or `-v false`.

### More Examples

Show disk space used/free on a Mac's main hard drive:

```
➜  ~   export TEXT=`df -h | grep disk1s1`
➜  ~   echo $TEXT | rexe -ms "x = self.split; puts %Q{#{x[4]} Used: #{x[2]}, Avail #{x[3]}}"
91% Used: 412Gi, Avail 44Gi
```


Print yellow (trust me!):

```
`➜  ~   cowsay hello | rexe -me "print %Q{\u001b[33m}; puts self.to_a"
  _______
 < hello >
  -------
         \   ^__^
          \  (oo)\_______
             (__)\       )\/\
                 ||----w |
                 ||     ||`
```


Add line numbers to the first 3 files in the directory listing:

```
➜  ~   ls | rexe -me "self.first(3).each_with_index { |ln,i| puts '%5d  %s' % [i, ln] }; nil"

    0  AndroidStudioProjects
    1  Applications
    2  Desktop
```
    

Add the current date/time to the first 3 files in the directory listing, this time using the `head` utility
instead of Ruby to truncate the array of lines:

```
➜  ~   ls -l | head -3 | rexe -ms "require 'date'; print DateTime.now.iso8601 + ' : ' + self"

2019-02-25T11:45:50+07:00 : total 2387104
2019-02-25T11:45:50+07:00 : drwxr-xr-x     4 kbennett  staff        128 Jul 27  2017 AndroidStudioProjects
2019-02-25T11:45:50+07:00 : drwx------     8 kbennett  staff        256 Sep  4 12:09 Applications
```

### Conclusion

`rexe` is not revolutionary technology, it's just plumbing that removes low level
configuration from your command line so that you can focus on the high level
task at hand.

When we think of a new piece of software, we usually think "what would this be
helpful with now?". However, the power of `rexe` is not so much what can be done
with it in a single use case now, but rather what will it do for me as I get
used to the concept and my supporting code and its uses evolve.

I suggest starting to use `rexe` even for modest improvements in workflow, even
if it doesn't seem compelling. There's a good chance that as you use it over
time, new ideas will come to you and the workflow improvements will increase
exponentially.
