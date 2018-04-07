---
id: 508
title: class_eval, instance_eval, eval
date: 2012-01-28T16:17:08+00:00
author: keithrbennett
guid: http://krbtech.wordpress.com/?p=508
permalink: /index.php/2012/01/28/class_eval-instance_eval-eval/
jabber_published:
  - "1327785429"
publicize_results:
  - 'a:2:{s:7:"twitter";a:1:{i:14401983;a:2:{s:7:"user_id";s:13:"keithrbennett";s:7:"post_id";s:18:"163370058670800896";}}s:2:"fb";a:1:{i:623669774;a:2:{s:7:"user_id";s:9:"623669774";s:7:"post_id";s:17:"10150532283844775";}}}'
email_notification:
  - "1327785430"
categories:
  - Uncategorized
---
A couple of days ago I attended an interesting discussion of metaprogramming by Arild Shirazi at a meeting of the Northern Virginia Ruby User Group. Arild showed how he used metaprogramming (_class_eval_ in particular) to generate functions whose names would only be known at runtime. His talk was very effective at reminding me that I don&#8217;t know as much about metaprogramming as I thought!

(Feel free to offer suggestions and corrections, and I&#8217;ll try to update the article accordingly.)

Dave Thomas, in his excellent Advanced Ruby training, emphasizes the value of knowing just who _self_ is at any point in the code. (For a good time, bounce around an rspec source file and try to guess what _self_ is in various places...).

_class_eval_ provides an alternate way to define characteristics of a class. It should be used only when absolutely necessary. The only legitimate use I can think of is when the necessary code cannot be known until runtime.

Knowing very little about _class_eval_, I assumed that it changed self to be the class of the current value of self. I was wrong. class_eval doesn&#8217;t change self at all; in fact, in this respect it functions identically to eval:

```ruby
>> class ClassEvalExample
>   class_eval "def foo; puts 'foo'; end"
> end
> ClassEvalExample.new.foo
foo
```

_eval_ appears to do the exact same thing:

```ruby
>> class EvalExample
>   eval "def foo; puts 'foo'; end"
> end
> EvalExample.new.foo
foo
```

There is a difference, though, when you call them outside the class definition. For a class C, you can call C.class_eval, but not C.eval:

```ruby
>> class C1; end
> C1.class_eval "def foo; puts 'foo'; end"
> C1.new.foo
foo

> class C2; end
> C2.eval "def foo; puts 'foo'; end"
NoMethodError: private method `eval' called for C2:Class
	from (irb):2
	from :0
```

If class_eval could be used to define an instance method on a class in a class definition _outside_ a function, what would happen if it were used _inside_ a function, where self is no longer the class, but the instance of the class? Would it define a method on the singleton class (a.k.a. _eigenclass_)? Let&#8217;s try it:

```ruby
>:001 > class D
 :002?>     def initialize
 :003?>         puts "In initialize"
 :004?>         class_eval "def foo; puts 'foo'; end"
 :005?>       end
 :006?>   end
 => nil
 :007 >
 :008 >   D.new.foo
In initialize
NoMethodError: undefined method `class_eval' for #
	from (irb):4:in `initialize'
	from (irb):8:in `new'
	from (irb):8
	from :0
```

No, this didn&#8217;t work...but wait a minute, isn&#8217;t class_eval a Kernel method? Let&#8217;s find out:

```ruby
> Kernel.methods.include? 'class_eval'
=> true
```

Alas, I was asking the wrong question. I should have asked if Kernel had an _instance_ method named _class_eval_:

```ruby
> Kernel.instance_methods.include? 'class_eval'
=> false
```

It doesn&#8217;t, but _Class_ does:

```ruby
> Class.instance_methods.include? 'class_eval'
=> true
```

...which is why the Kernel.methods.include? above worked.

Although _class_eval_ didn&#8217;t work, _instance_eval_ will work:

```ruby
> class F
>   def initialize
>     instance_eval 'def foo; puts "object id is #{object_id}"; end'
>   end
> end
> F.new.foo
object id is 2149391220
> F.new.foo
object id is 2149362060
```

To illustrate that foo has not been created as a class or member function on class F, but only on object f:

```ruby
>> F.methods(false).include? 'foo'
 => false
> F.instance_methods(false).include? 'foo'
 => false
> f = F.new
> f.methods(false).include? 'foo'
 => true
```

Could _eval_ be substituted for _instance_eval_ in the same way as it was for _class_eval_? Let&#8217;s find out...

```ruby
>>   class F2
>     def initialize
>         eval 'def foo; puts "object id is #{object_id}"; end'
>     end
> end
> F2.new.foo
object id is 2149180440
```

Apparently, yes. However, similarly to _class_eval_, _instance_eval_ can be called outside of a class definition, but _eval_ cannot:

```ruby
>> class C; end
> c = C.new
> c.instance_eval 'def foo; puts "object id is #{object_id}"; end'
> c.foo
object id is 2149446940

> class D; end
> d = D.new
> d.eval 'def foo; puts "object id is #{object_id}"; end'
NoMethodError: private method `eval' called for #
	from (irb):7
	from :0
```

Hmmm, I wonder, if we can define a _function_ using the eval methods, can we also declare an instance _variable_?:

```ruby
># First, class_eval:
> class E
>   class_eval "@@foo = 123"
>   def initialize; puts "@@foo = #{@@foo}"; end
>   end
> E.new
@@foo = 123

# Next, instance_eval:
> o = Object.new
> o.instance_eval '@var = 456'
> o.instance_eval 'def foo; puts "@var = #{@var}"; end'
> o.foo
@var = 456
```

What&#8217;s interesting is that we created instance variable _var_ in instance _o_, but its class Object knows nothing about this new variable. In the data storage world, this would be analogous to using a document store such as MongoDB and adding a variable to a single document, unlike in an RDBMS where you would have to add it to the table definition and include it in all rows of the table.

Techniques such as these are cool and powerful, but are not without cost. If your code accesses a function or variable that is not defined in a standard class definition, the reader may have a hard time tracking down the creation and meaning of that function or variable. We should be kind to our fellow developers and use these techniques only when absolutely necessary.
