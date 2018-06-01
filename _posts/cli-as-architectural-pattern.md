---
title: The Command Line Interface as an Architectural Pattern
date: 2018-04-20
---

In these days of web and mobile apps, the ancient yet ever useful command line program don't get no respect.

It turns out that command line applications offer some great benefits for starting and growing a focused code base.

All one has to do is add a command line interface to the lower level code.

This can be a very thin wrapper.

### Use Case

I recently spoke with a colleague about a software need he has. He periodically gets data files from about 75 different sources, and needs to normalize them into a unified schema. I suggested he use my [`wifi-wand`](https://github.com/keithrbennett/wifiwand) command line application as a starting point and replace code to fit his use case. This kind of approach would offer the following benefits:

# Because it is written in Ruby:

* a rich collection of libraries is available
* providing a shell for an interactive mode is simple
* Ruby's `method_missing` feature makes it simple to support multiple function forms
* no explicit build or compilation is necessary


# Because it is organized as a Ruby gem:

* all code resides in a neat package
* providing an executable to drive the code is supported out of the box
* user upgrades are simple
* installation of dependencies (other Ruby gems) is automatic

You're going to 


### Separating the Models from the Command Line Interface

### Providing a Shell

### Testing It

### Running It

### Command Line
  * Short and Long Names
  
  
Help text is documentation

Think in context of Steven's use case; workflow

the CLI will be helpful in using it more, increasing "test" coverage, exposing more edge cases

### Why Ruby Is So Good for This

optional parentheses, method_missing
-> great command experience

interpreted, not compiled
toolsets
JRuby! Access Java code

