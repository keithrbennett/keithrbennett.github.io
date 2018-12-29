---
title: The `rb` Command Line Filter
date: 2018-12-30
---

Show disk space used/free:

`df -h | rb "x = self.grep(/disk1s1/).first.split; puts %Q{#{x[4]} Used: #{x[2]}, Avail #{x[3]}}"`


Print yellow:

`cowsay hello | rb "print %Q{\u001b[33m}; puts self.to_a.join"`


Add line numbers:

`ls | rb "self.each_with_index { |ln,i| puts '%5d  %s' % [i, ln] }"`


Add date/time:

ls -l | rb -l "require 'date'; print DateTime.now.iso8601 + ' : ' + self"
