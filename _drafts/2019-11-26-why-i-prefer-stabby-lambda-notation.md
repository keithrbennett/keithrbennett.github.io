---
title: Why I Prefer Stabby Lambda Notation
published: false
---

### The Stabby Lambda (`->`)
Although the `->` "stabby lambda" notation has been available for creating lambdas since Ruby version 1.9, acceptance and adoption has been slow. In this article I will explain why I recommend using it instead of the `lambda` notation.

In a previous article, "[lambdas Are Better Than procs](https://dev.to/keithrbennett/lambdas-are-better-than-procs-52a1)", I proposed that lambdas should be used rather than procs in almost all cases, given that they are safer in terms of argument count checking and return behavior.

So it makes sense that `->` should create a lambda and not a proc. (As an aside, it always puzzles me when people use the term stabby _proc_, when it creates a lambda.)

### `->`'s Picture-Like Notation

The picture-like notation `->` is quite different from the `lambda` and `proc` forms, because although all result in method calls that create `Proc` instances, `lambda` and `proc` _look like_ method calls, while `->` does not, instead appearing more like a _language construct_. On the higher level, it really _is_ a language construct, and the fact that a method needs to be called to create it is an implementation detail that should not matter to the programmer.
 
The striking appearance of `->` says to the reader "take note, something different is happening here, this is the definition of a executable code that will probably be called somewhere _else_". If a picture is worth a thousand words, then a text picture like `->` is worth, well, at least ten.
 
In addition, the conciseness of the notation lowers the cost of using it (in space on the line, if not typing speed), thereby encouraging its use. 

### The Need for Visual Differentiation

Unlike other code in a method, a lambda's code is not called in sequence (unless it is immediately called as a self invoking anonymous function, but this is rare). Also, sometimes a lambda can be used as if it were a nested method, containing lower level code that may be called multiple times in the method. For these reasons, a pictorial indication setting it apart from other code in the method is especially helpful.

### Rubocop

Rubocop is a very useful tool for normalizing code style. For better or worse though, Rubocop's defaults constitute implicit recommendations, and deviating from the defaults can require lengthy and contentious team discussions. Because of the potentially high cost of overriding the defaults, it is important that the basis in reasoning for the selection of the default be sound.

Rubocop's [default setting for lambdas](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Lambda) is to use `->` with lambda one-liners but `lambda` for multiline lambdas . While this is not a matter of monumental importance, I believe it's misguided and should be changed.

My guess is that it is intended to mirror the Ruby code block notation convention of `{..}` for single line blocks and `do...end` for multi-line blocks. However, in the code block case the `do` and `end` are at the beginning of the line and easy to spot and mentally parse, whereas the `lambda` is likely in the middle of the line and does not stand out as would the `->`.

I believe that the Rubocop default should be changed to prefer `->` in all cases. At minimum, using it should not cause a violation and both forms should be acceptable.

### Conclusion

Lambdas are, thankfully, first class objects in Ruby. That is, they can be passed to and returned from methods, and can be assigned to variables. This is a pretty major construct, and I believe a major form of notation (`->`), rather than a method name (`lambda`) is justified and helpful.

The conciseness and pictorial nature of `->` encourage the use of lambdas, and in my opinion, that is a Good Thing, as lambdas are underused in the Ruby community, resulting in many missed opportunities for cleaner and clearer code.


