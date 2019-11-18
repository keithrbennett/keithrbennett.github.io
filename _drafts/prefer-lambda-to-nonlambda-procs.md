---
title: Prefer Lambda to Nonlambda Procs
---


It's unfortunate that the great functional features of Ruby are not used more widely. This article is one of several in which I share some things that will hopefully remedy that, if even a little (1).


Functional programming in Ruby is productive and fun, but unfortunately is a lesser known aspect of the language. I'd like to clarify something I believe is important about `Proc`s.

First, my suggestion, and then the justification:

**Prefer lambda to nonlambda procs.**

There are many resources explaining the difference between lambda and nonlambda procs, but here are some basics:

`Proc` is the name of the class with which `lambda`s and (nonlambda `proc`s are created. (This terminology is unfortunate, as `Proc` and `proc`, when spoken, sound identical.) In other words:

* all `lambda`s are `Proc`s
* all `proc`s are `Proc`s
* a `Proc` instance can be either a `lambda` or a `proc`
* code blocks behave like `proc`s

----

### Arity (Argument Count) Checking Behavior Differences

A `lambda`, like a method, strictly enforces its argument count, but a `proc` does not. When we call a `proc` with the wrong number of arguments, there are no complaints by the Ruby runtime:

```
2.6.5 :006 > pfn = Proc.new { |arg| }
 => #<Proc:0x00007f93828bd298@(irb):6>
2.6.5 :007 > pfn.call
 => nil
```

In contrast, when we do the same with a lambda, we get an error (1)(2):

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
 
What happens when you pass a code block somewhere, and it executes a `return`? Does it return from the block? No, it returns from the method that yielded to the block. `proc`s behave the same way:

```
def using_proc
  pfn = Proc.new { return }
  puts "Before calling"
  pfn.call
  puts "After calling"
end

# ...
2.6.5 :015 > using_proc
Before calling

```

Before proceeding to the lambda behavior, I'd like to point out that this `proc` behavior is such that implicit and explicit returns do very different things! An implicit return will return from the proc, but an explicit return will return from the context that called it! Here is the same code, but without the explicit return; the proc will end and exit naturally:

```
def using_proc_without_return
  pfn = Proc.new { }
  puts "Before calling"
  pfn.call
  puts "After calling"
end
# ...
2.6.5 :007 > using_proc_without_return
Before calling
After calling
```

You may have learned that a `return` at the end of a method is redundant (it _is_, of course), but in the case of the `proc` it is not!

In contrast, a `lambda`s `return` returns from itself to the context that called it:

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
----



(1) Other articles include:
* [Using Lambdas to Simplify Varying Behaviors in Your Code](https://dev.to/keithrbennett/using-lambdas-to-simplify-varying-behaviors-in-your-code-1d5ff)
* [Ruby Enumerables Make Your Code Short and Sweet](https://dev.to/keithrbennett/ruby-enumerables-make-your-code-short-and-sweet-2nl0)

(2) I've used the `.call` variant of calling a Proc because it is the most obvious for the reader, but in practice I prefer the shorthand notation `.()`.

(3) The shorthand `->` can be used in place of the `lambda` keyword to more succinctly define a lambda.


