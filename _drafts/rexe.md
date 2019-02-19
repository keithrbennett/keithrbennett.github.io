---
title: The `rexe` Command Line Filter and Executor
date: 2019-02-15
---

I love the power of the command line, but not the awkwardness of shell scripting languages. Sure, there's a lot that can be done with them, but it doesn't take long before I get frustrated with the bluntness and verbosity.

Often, I solve this problem by writing a Ruby script instead. Ruby gives me fine grained control in a "real" programming language with which I am comfortable. However, when there are multiple OS commands to be called, then Ruby can be awkward too.

For simple tasks it's possible to call Ruby on the command line (I use intermediate shell variables for a shorter and simpler command:

```
export JSON_TEXT=`curl https://api.exchangeratesapi.io/latest`
echo $JSON_TEXT | ruby -r json -r awesome_print -e 'ap JSON.parse(STDIN.read)'
```

However, the length and complexity of the line is a disincentive to its use, and this approach is often abandoned.

The `rexe` script (coincidentally, written by me!) at https://github.com/keithrbennett/rexe (`gem install rexe`) provides several ways to simplify this, tipping the scale so that using Ruby can be used practically and simply on the command line more often.

For consistency with the `ruby` interpreter we called previously, `rexe` supports requires with the `-r` option, but also allows grouping them together:

```
echo $JSON_TEXT | rexe -r json,awesome_print -mb 'ap JSON.parse(STDIN.read)'
```

And, with several configuration approaches, the requires of `json` and `awesome_print` can be excluded from the command line so that the command is simplified:



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
