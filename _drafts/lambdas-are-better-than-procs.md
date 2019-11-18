---
title: lambdas Are Better Than procs
---

Functional programming in Ruby is productive and fun, but sadly it's a lesser known aspect of the language. This article is one of several in which I share some things that will hopefully remedy that, if even a little (1).

Many Rubyists believe that lambda and nonlambda Procs are pretty much the same and that choosing which one to use is a subjective preference. This is an unfortunate fallacy.

This article will attempt to achieve two purposes:

1) to explain the difference between lambdas and procs

2) to persuade you to use lambdas unless there is a compelling reason not to

There are many resources available that explain lambdas and procs, and I will assume you know at least a little about them.

Here are some important points:

* a `Proc` instance can be either lambda or a proc (2)
* all `lambda`s are `Proc`s
* all `proc`s are `Proc`s
* code blocks behave like `proc`s
* you can determine the kind of Proc by calling `lambda?` on it

----

### Arity (Argument Count) Checking Behavior Differences

A `lambda`, like a method, strictly enforces its argument count, but a `proc` does not. When we call a `proc` with the wrong number of arguments, there are no complaints by the Ruby runtime (3):

```
2.6.5 :006 > pfn = proc { |arg| }
 => #<Proc:0x00007f93828bd298@(irb):6>
2.6.5 :007 > pfn.call
 => nil
```

In contrast, when we do the same with a lambda, we get an error (4):

```
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

```
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

Before proceeding to the lambda behavior, I'd like to point out that this `proc` behavior is such that implicit and explicit returns do very different things! An implicit return will return from the proc, but an explicit return will return from the context that called it! Weird, eh? Here is the same code, but without the explicit return; the proc will end and exit naturally:

```
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

```
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

### A `lambda` Resembles a Method More Closely Than Does a `proc`

In both of the above cases, the lambda behaves more like a method than does a proc. In fact, the newer `->(...)` notation for creating a lambda reveals that intent since its syntax defines the arguments as does a method's syntax, and is therefore preferable to the older `lambda` notation:

New:

```
fn = ->(arg1, arg2) { ... }
```

Old:

```
fn = lambda { |arg1, arg2| ... }
```

----

### Conclusion

There is a principle in software engineering, but I can't name it. These phrases come to mind: "limit things to the narrowest possible scope", "specify things with minimal ambiguity", "use language features that minimize the risk of errors".

Based on everything said so far, the lambda variant of Proc is clearly the winner.
 
You may think you don't need the added protection of the lambda. Maybe you're never calling the lambda yourself, but passing it to a framework such as Rails that is doing all the calling. Nevertheless, if given the added protection for free, why would you _not_ want it? Especially since the `->` notation is somewhat pictorial and more concise?

----

### Footnotes

(1) Other articles and a conference talk include:
* [Using Lambdas to Simplify Varying Behaviors in Your Code](https://dev.to/keithrbennett/using-lambdas-to-simplify-varying-behaviors-in-your-code-1d5ff)
* [Ruby Enumerables Make Your Code Short and Sweet](https://dev.to/keithrbennett/ruby-enumerables-make-your-code-short-and-sweet-2nl0)
* [Functional Programming in Ruby](https://www.youtube.com/watch?v=nGEy-vFJCSE), video of a talk given at Functional Conf in Bangalore, India in 2014 

(2) This terminology is unfortunate, as `Proc` and `proc`, when spoken, sound identical.

(3) In this article I've used the `.call` variant of calling a Proc because it is the most obvious for the reader, but in practice I prefer the shorthand notation `.()`.

(4) The shorthand `->` can be used in place of the `lambda` keyword to more succinctly define a lambda.


