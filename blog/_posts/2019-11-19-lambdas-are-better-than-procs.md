---
title: lambdas Are Better Than procs
published: true
---

Many Rubyists believe that lambda and nonlambda Procs are pretty much the same and that choosing which one to use is a subjective preference. This is an unfortunate fallacy.

This article will attempt to achieve two purposes:

1) to explain the difference between lambdas and procs

2) to persuade you to use lambdas unless there is a compelling reason not to

There are many resources available that explain lambdas and procs <sup id="a1">[[1](#f1)]</sup>, and I will assume you know at least a little about them.

Before we look at some examples, here are some characteristics of lambdas and procs:

* a `Proc` instance can be either lambda or a proc <sup id="a2">[[2](#f2)]</sup>
* all `lambda`s are `Proc`s
* all `proc`s are `Proc`s
* code blocks behave like `proc`s
* you can determine the kind of Proc by calling `lambda?` on it

----

### Arity (Argument Count) Checking Behavior Differences

A `lambda`, like a method, strictly enforces its argument count, but a `proc` does not. When we call a `proc` with the wrong number of arguments, there are no complaints by the Ruby runtime <sup id="a3">[[3](#f3)]</sup>:

```ruby
2.6.5 :006 > pfn = proc { |arg| }
 => #<Proc:0x00007f93828bd298@(irb):6>
2.6.5 :007 > pfn.call
 => nil
```

In contrast, when we do the same with a lambda, we get an error <sup id="a4">[[4](#f4)]</sup>:

```ruby
2.6.5 :002 > lfn = ->(arg) {}
    => #<Proc:0x00007f9383118ed8@(irb):2 (lambda)>
   2.6.5 :003 > lfn.call
   ...
   ArgumentError (wrong number of arguments (given 0, expected 1))
```

Which behavior would _you_ prefer?

Clearly, arity checking is helpful, and we abandon it at our peril.

----

### Return Behavior Differences
 
What happens when you pass a code block somewhere, and it executes a `return`? Does it return from the block? Well, yes, but it does much more than that; it returns from the method that _yielded_ to the block. `proc`s behave the same way; in addition to returning from themselves, they will return from the method in which they were called:

```ruby
def using_proc
  pfn = proc { return }
  puts "Before calling"
  pfn.call
  puts "After calling"
end

# ...
2.6.5 :015 > using_proc
Before calling

```

Before proceeding to the lambda behavior, I'd like to point out that this `proc` behavior is such that implicit and explicit returns do very different things. An implicit return will return from the proc, but an explicit return will return from the context that called it! Weird, eh? Here is the same code, but without the explicit return; the proc will end and exit naturally:

```ruby
def using_proc_without_return
  pfn = proc { }
  puts "Before calling"
  pfn.call
  puts "After calling"
end
# ...
2.6.5 :007 > using_proc_without_return
Before calling
After calling
```

When we first learn Ruby, we learn that a `return` at the end of a method is redundant (it _is_, of course), but in the case of the `proc` (and code block) it is not!

In contrast, a `lambda`'s `return` returns from itself to the context that called it:

```ruby
def using_lambda
  lfn = -> { return }
  puts "Before calling"
  lfn.call
  puts "After calling"
end
# ...
2.6.5 :008 > using_lambda
Before calling
After calling
```

----

### A `lambda` is More Method-Like Than a `proc`

In both of the above cases, the lambda behaves more like a method than a proc does. The newer `->(args)` notation for creating a lambda reveals that intent by defining the arguments as a method does, in a parenthesized list, and is therefore preferable to the older `lambda` notation:

New:

```ruby
fn = ->(arg1, arg2) { ... }
```

Old:

```ruby
fn = lambda { |arg1, arg2| ... }
```

----

### Conclusion

Here are some principles I've learned to code by:

* prefer simplicity to complexity
* limit things to the narrowest possible scope
* specify things with minimal ambiguity
* use language features that minimize the risk of errors

Regarding everything said so far, the lambda wins over the proc. There is no reason to use a proc unless you specifically need the odd and potentially hazardous behaviors described above.
 
You may think it will never matter in your case. Maybe you're never calling the lambda yourself, but passing it to a framework such as Rails that is doing all the calling. Nevertheless, if given the added protection for free, why would you _not_ want it? Especially since the `->` notation is somewhat pictorial and more concise?

----

### Footnotes

<b id="f1">[1]</b> There are many good resources; here are some that I have produced (articles and a conference talk):

* [Using Lambdas to Simplify Varying Behaviors in Your Code](https://dev.to/keithrbennett/using-lambdas-to-simplify-varying-behaviors-in-your-code-1d5ff)
* [Ruby Enumerables Make Your Code Short and Sweet](https://dev.to/keithrbennett/ruby-enumerables-make-your-code-short-and-sweet-2nl0)
* [Functional Programming in Ruby](https://www.youtube.com/watch?v=nGEy-vFJCSE), video of a talk given at Functional Conf in Bangalore, India in 2014
[↩](#a1)

<b id="f2">[2]</b>This terminology is unfortunate, as `Proc` and `proc`, when spoken, sound identical.
[↩](#a2)

<b id="f3">[3]</b>In this article I've used the `.call` variant of calling a Proc because it is the most obvious for the reader, but in practice I prefer the shorthand notation `.()`.
[↩](#a3)

<b id="f4">[4]</b>The shorthand `->` can be used in place of the `lambda` keyword to more succinctly define a lambda.
[↩](#a4)

----

This article may be improved over time. To see its revisions you can go to its [Github commit history](https://github.com/keithrbennett/keithrbennett.github.io/commits/master/blog/_posts/2019-11-19-lambdas-are-better-than-procs.md).
