---
id: 698
title: "Ruby's Forwardable"
date: 2012-09-13T11:02:24+00:00
author: keithrbennett
guid: http://www.bbs-software.com/blog/?p=698
permalink: /index.php/2012/09/13/rubys-forwardable/
categories:
  - Uncategorized
---
Last night I had the pleasure of attending the [Arlington Ruby User Group](http://www.meetup.com/Arlington-Ruby/) meeting in Arlington, Virginia. Marius Pop, a new Rubyist, presented on Ruby&#8217;s [Forwardable](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/forwardable/rdoc/Forwardable.html) module. Forwardable allows you to very succinctly specify that you want to define a method that simply calls (that is, delegates to) a method on one of the object&#8217;s instance variables, and returns its return value, if there is one. Here is an example file that illustrates this:

```ruby
>require 'forwardable'

class FancyList
  extend Forwardable
  
  def_delegator :@records, :size
  
  def initialize
    @records = []
  end
  
end

puts "FancyList.new.size = #{FancyList.new.size}"
puts "FancyList.new.respond_to?(:size) = #{FancyList.new.respond_to?(:size)}"

# Output is:
# FancyList.new.size = 0
# FancyList.new.respond_to?(:size) = true
```

After the meeting I thought of a class I had been working on recently that would benefit from this. It&#8217;s the [LifeTableModel](https://github.com/keithrbennett/life_game_viewer/blob/a56d329901999b20a2b23117d2fe2a8155a3799a/lib/life_game_viewer/view/life_table_model.rb "LifeTableModel class") class in my [Life Game Viewer](https://github.com/keithrbennett/life_game_viewer) application, a Java Swing app written in JRuby. The LifeTableModel is the model that backs the visual table (in Swing, a _JTable_). Often the table model will contain the logic that provides the data to the table, but in my case, it was more like a thin adapter between the table and other model objects that did the real work.

It turned out that almost half the methods were minimal enough to be replaced with Forwardable calls. The diff is shown here:

[gist id=3713110]

The modified class is viewable on Github [here](https://github.com/keithrbennett/life_game_viewer/blob/6a44806a15e708068258f30b45c60c36a2142d87/lib/life_game_viewer/view/life_table_model.rb).

As you can see, there was a substantial reduction in code, and that is always a good thing as long as the code is clear. More importantly, though, `def_delegator` is much more expressive than the equivalent standard method definition. It&#8217;s much more precise because it says this function delegates to another class&#8217; method _exactly_, in no way modifying the behavior or return value of that other function. In a standard method definition you&#8217;d have to inspect its body to determine that. That might seem trivial when you&#8217;re considering one method, but when there are several it makes a big difference.

One might ask why not to use inheritance for this, but that would be impossible because:

a) the class delegates to three different objects, and
  
b) the class already inherits from AbstractTableModel, which provides some default Swing table model functionality.

Marius showed another approach that delegates to the other object in the method_missing function. This would also work, but has the following issues:

a) It determines whether or not the delegate object can handle the message by calling its _respond_to_ method. If that delegate intended to handle the message in its method\_missing function, respond\_to will return false and the caller will not call it, calling its superclass&#8217; method_missing instead.

b) The delegating object will itself not contain the method. (Maybe the method\_missing handling adds a function to the class, but even if it does, that function will not be present when the class is first loaded.) So it too will return a misleading false if respond\_to is called on it.

c) In addition to not communicating its capabilities to objects of other classes, it does not communicate to the human reader what methods are available on the class. One has to look at the class definition of the delegate object, and given Ruby&#8217;s duck typing, that may be difficult to find. It could even be impossible if users of your code are passing in their own custom objects. This may not be problematic, but it&#8217;s something to consider. (I talk more about duck typing&#8217;s occasional challenges at [Design by Contract, Ruby Style](http://www.bbs-software.com/blog/2011/06/15/dependency-inversion-ruby-style/).)

It was an interesting subject. Thank you Marius!