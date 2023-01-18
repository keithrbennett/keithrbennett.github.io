---
title: I Miss Java's Void Keyword in Ruby
published: false
tags: java, ruby, void

As a devoted Ruby developer, I often kid that I am a "refugee from Javaland". Working with Java for over ten years, it became painful dealing with all the ceremony and verbosity of that language and its ecosystem.
 
However, I have come to miss _some_ Java features. One of them is the ability to mark a method as having no meaningful return value as `void`.

When I say _meaningful_ return value, I say that because in Ruby, all methods return a value; in the absence of an explicit return value, `nil` is returned.

Because of this, it is sometimes difficult to know by looking at a method if the nil value returned has any meaning. In Java, the `void` keyword applied to a method tells the compiler and the reader that this method will not return _anything_.

A similar Ruby `void` keyword might not prevent a method from returning nil, but it _could_ be used at runtime to check that no value _other than nil_ is returned. It might also check at runtime that the caller is not using the returned `nil`.

This would, of course, slow down the runtime somewhat, but if it were controlled by a Ruby command line option or environment variable, then the user could enable it selectively.

Even if that runtime checking were _never_ enabled, IDE's and other code analyzers could use it.

Why is this important or helpful? If you are writing a method that others will subclass, then it will be obvious whether or not to return a value in the subclass methods.

If you are using methods in a library, and those methods are returning the value of another method, how do you know if the return value is intentional or coincidental? How do you know if other implementations of that method

To take this further, if I could mark all methods without meaningful return values as `void`, then I could assume that for all the _other_ methods, return values _were_ meaningful. For those methods, it would be nice to require that return values be specified explicitly.

I once worked on a legacy code base with over a hundred implementations of a method in a common superclass. These methods returned meaningful values. Idiomatic Ruby is to let a method return nil without any explicit return statement or value, so many of them had code like this:

```ruby
def foo
  return 'something' if a_condition
end
```

...but sometimes with significant complexity in the method. Note that only one of the two possible return values are explicit; nil can be returned implicitly. We were changing our logging implementation, and the previous one returned nil in unit tests, so this worked:

```ruby
def foo
  begin
    do_something
  rescue => e
    logger.error(e)
  end
end
```

`do_something` returned a truthy value, and the old logger always returned nil, so this worked. However, the new logger returned true or false, depending on whether or not the message was logged. To make matters worse, callers were testing with `.nil?` rather than testing for falsiness (e.g. `if foo(...)` or `unless foo(...)`).


