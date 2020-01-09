---
title: The Case for Stabby Lambda Notation
published: true
---

### The Stabby Lambda (`->`)

Although the `->` "stabby lambda" notation has been available for creating lambdas since Ruby version 1.9, old habits die hard and acceptance and adoption has been slow. In this article I will explain why I recommend using it instead of the `lambda` notation.

### Stabby Notation as an Indicator of Preferred and Default Proc Type

In a previous article, "[lambdas Are Better Than procs](https://dev.to/keithrbennett/lambdas-are-better-than-procs-52a1)", I proposed that lambdas should be used rather than procs in almost all cases, given that they are safer in terms of argument count checking and return behavior.

So it makes sense that `->` should create a lambda and not a proc. (As an aside, it always puzzles me when people use the term stabby _proc_, when it creates a lambda.)

One way to look at it is, by using the stabby lambda notation, we are
saying "make me Ruby's implementation of an objectless function". This is at a level higher than "make me a lambda" or "make me a proc", and is probably a better interface to the programmer, especially the newer Rubyist.


### `->`'s Picture-Like Notation

The picture-like notation `->` is quite different from the `lambda` and `proc` forms, because although all result in method calls that create `Proc` instances, `lambda` and `proc` _look like_ method calls, while `->` does not, instead appearing more like a _language construct_. On the higher level, it really _is_ a language construct, and the fact that a method needs to be called to create a lambda is an implementation detail that should not matter to the programmer.
 
The striking appearance of `->` says to the reader "take note, something different is happening here, this marks the beginning of a definition of executable code that will probably be called somewhere _else_". If a picture is worth a thousand words, then a text picture like `->` is worth, well, at least ten.
 

### The Need for Visual Differentiation

Unlike other code in a method, a lambda's code is not called in sequence (unless it is immediately called as a self invoking anonymous function, but this is rare). Also, sometimes a lambda can be used as if it were a nested method, containing lower level code that may be called multiple times in the method in which it was defined. For these reasons, a pictorial indication setting it apart from other code in the method is especially helpful.

### Rubocop

Rubocop is a very useful tool for normalizing code style. For better or worse though, Rubocop's defaults constitute implicit recommendations, and deviating from the defaults can require lengthy and contentious team discussions. Because of this potentially high cost of overriding the defaults, it is important that the basis in reasoning for the selection of the default be sound.

Rubocop's [default setting for lambdas](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Lambda) is to use `->` with lambda one-liners but `lambda` for multiline lambdas. While this is not a matter of monumental importance, I believe it's misguided and should be changed.

My guess is that it is intended to mirror the Ruby code block notation convention of `{..}` for single line blocks and `do...end` for multi-line blocks. However, the code block case is different because the `do` and `end` are at the end and beginning of the line, respectively (though it is true that if there are arguments they will appear after the `do`). Although the indentation of the code block within the `lambda do...end` makes it easy to see that _something_ is going on, it is easy to miss the `lambda` and assume it is a normal code block. The pictorial nature of `->` reduces this risk.

I believe that the Rubocop default should be changed to prefer (or at minimum permit) `->` in all cases.

Note: Since writing this article I posted an issue on the Rubocop project site 
[here](https://github.com/rubocop-hq/rubocop/issues/7566).

### Conclusion

Lambdas are, thankfully, first class objects in Ruby. That is, they can be passed to and returned from methods, and can be assigned to variables. This is a pretty major construct, and I believe a special notation (`->`), rather than a method name (`lambda`) is justified and helpful. While it is true that `class`, `module`, and `def` also mark the beginning of major language constructs, they are likely to be the first token on a line, whereas lambdas are usually assigned to variables or passed to methods or other lambdas, and are not.

The conciseness and pictorial nature of `->` encourage the use of lambdas, and in my opinion, that is a Good Thing. Lambdas are underused in the Ruby community, and many opportunities for cleaner and clearer code are missed.

----

This article may be improved over time. To see its revisions you can go to its [Github commit history](https://github.com/keithrbennett/keithrbennett.github.io/commits/master/blog/_posts/2019-11-30-why-i-prefer-stabby-lambda-notation.md).
