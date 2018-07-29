---
title: Simplify Your Code with Lambdas and Other Callables
date: 2018-07-16
---

[Lambdas](https://en.wikipedia.org/wiki/Anonymous_function), which, unlike methods, are functions not bound to any object, are best known in the context of [functional programming](https://en.wikipedia.org/wiki/Functional_languages) languages. However, even [object oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) languages that support lambdas, such as Ruby, can greatly benefit from their use.

The procedural `if-elsif-end` or `case` clauses work when you have a small number of conditions and actions that are known in advance, but if you don't, they're pretty useless.

And although the object oriented approach of [polymorphism](https://en.wikipedia.org/wiki/Polymorphism_(computer_science)) by inheritance (1) can produce a correct result, in many cases it is unnecessarily verbose, ceremonial, and awkward.

Furthermore, though we're accustomed to thinking about this problem in the context of a _single_ customizable behavior, what if there are several?

Let's say we have a class that contains 3 varying behaviors. As an admittedly contrived example, let's say we have classes for different types of animals, and they each have a `move`, `sleep`, and `vocalize` behavior. As a simplifying assumption, let's say that each of these behaviors has 7 possible variations. If we were to write a class to implement each possible set of behaviors, we would need the [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product) of classes, (7 * 7 * 7), or 343 classes! That would be silly of course, since we could simplify it by providing a class hierarchy for each of the three kinds of behavior, and plug those into the larger class -- but then we would still need (7 + 7 + 7), or 21 classes! (Probably 24 really, as pure design would dictate an additional class as an abstract superclass for each set of 7 implementations).

If these behaviors are truly complex enough to justify a class of their own, this is not a problem. However, often they are not, and the solution is many times as verbose and complex as it needs to be.

A better solution is using callables such as lambdas.

----

#### Callables as a Superset of Lambdas

In traditional object oriented languages such as Java and C++, polymorphism is (in general) implemented by inheritance. Ruby does this also (2), but in addition, Ruby uses _duck typing_, meaning that _any_ object that responds to the method name can be used, regardless of its position in the class hierarchy. This means that in Ruby, since the method used to call a lambda is `call`, _any_ object that responds to `call` can be used in place of a lambda. It could be a lambda, an instance of a class, or even a class or module. This provides great flexibility in implementing varying behavior. You can choose what kind of object to use based on your situation. For complex behaviors you may want modules or classes, and for simpler behaviors a lambda will work just fine.

 Since any object responding to `call` can be used in place of a lambda, I will use the term _callable_ instead of _lambda_ where applicable.

----

### The Buffered Enumerable

I once worked on a project where I needed to implement buffering of multiple kinds of things received over network connections. I started writing the first one, and noticed how the code could be cleanly divided into two kinds of tasks: 1) knowing _when_ to fetch objects into the buffer and other buffer management tasks, and 2) _how_ to fetch each block of objects and what _else_ to do each time that fetch is performed (e.g. logging, displaying a message to the user, updating some external state).

Realizing that #1 would be common and identical to all cases, and only #2 would vary, I thought about how wasteful it would be to implement #1 separately in all cases. I thought about the admonition about high cohesion / low coupling, and the Unix axiom "do one thing well", and decided to separate the two. The most natural way to design this functionality in Ruby is with an `Enumerable`, which will have access to all kinds of functional wizardry thanks to the methods it gets for free by including the `Enumerable` module. In addition, it can easily used to generate an array by calling its `to_a` method.

This is the origin of the  [_BufferedEnumerable_](https://github.com/keithrbennett/trick_bag/blob/master/lib/trick_bag/enumerables/buffered_enumerable.rb) class in my [_trick_bag_](https://github.com/keithrbennett/trick_bag/) gem. This class manages buffering but has no idea how to fetch chunks of data, nor what else to do at each such fetch; for that, the caller provides callables such as lambdas. (Upon user request, the ability to subclass it and override its methods was also added.) The result is a dramatic simplification, where the logic of buffering is defined in only one place, and the places it is used need not be concerned with its implementation (or its testing!).

To create an instance of this with callables, we call the `BufferedEnumerable` class method `create_with_callables`, which is defined as follows:

```ruby
 def self.create_with_callables(chunk_size, fetcher, fetch_notifier = nil)
    instance = self.new(chunk_size)
    instance.fetcher = fetcher
    instance.fetch_notifier = fetch_notifier
    instance
  end
```

If a fetcher callable has been defined (as opposed to the use of the subclassing approach), it is called with the empty data buffer and the number of objects requested as shown below whenever the buffer needs to be filled:

```ruby
fetcher.(data, chunk_size)
```

(In Ruby, `.(` is an abbreviation for `.call(`.)

Here is a trivial fetcher that merely fills the array of the requested chunk size with random numbers:

```ruby
fetcher = ->(data, chunk_size) do
  chunk_size.times { data << Random.rand }
end
```

Here is a `pry` example that illustrates the call to that fetcher, and its effect on the passed array:

```
[7] pry("")> a = []; fetcher.(a, 2)
2
[8] pry("")> a
[
    [0] 0.4885287976297428,
    [1] 0.5493143769524284
]
```

After the buffer is filled, if a fetch notifier callable has been defined (unlike the fetcher, this is optional), it too is called, with the data buffer:


```ruby
fetch_notifier.(data)
```

A trivial fetch notifier might look like this:

```ruby
->(data) { puts "#{Time.now} Fetched #{data.size} objects" }
```

(`data.size` will not necessarily be equal to `chunk_size` on the last fetch.)

This notifier might produce something looking like this:

`2018-07-26 17:19:47 +0700 Fetched 1000 objects`

After defining the `fetcher` and `fetch_notifier` lambdas, we could call the class method shown above as follows:

```ruby
buffered_enumerable = BufferedEnumerable.create_with_callables( \
    1000, fetcher, fetch_notifier)
```

By parameterizing the behaviors with callables, we have increased the simplicity of the implementation by separating the two orthogonal tasks into separate code areas, and avoided the unnecessary overhead of the inheritance approach, which would have packaged these functions in classes.

----

### Using Predicate Callables to Implement Filters

_Predicates_ are functions that return a Boolean value, that is, either true or false. There are many use cases for predicates in software: filters, boundaries, triggers, authentication results...again, anything that produces a true or false value.

Configurable predicates are another natural fit for using callables.

I once had to write a [DNS mock server](https://github.com/keithrbennett/mock_dns_server) for network testing  that could be configured to respond with specific behaviors based on the characteristics of the incoming request. In another situation more recently, I was writing some accounting software and wanted to be able to filter the working set of transactions based on date, category, etc.

Both cases were an excellent fit for using callables as filters.

In the case of the mock DNS server, there were multiple criteria for the filters, such as _protocol_ (TCP vs. UDP), _qtype_ (question type), _qclass_ (question class), and _qname_ (question name). I provided methods that return lambdas that filter for specific values for those attributes; for example, for a filter that will return true only for the qname `example.com`, you would do the following:

```ruby
predicate_factory = MockDnsServer::PredicateFactory.new
filter = predicate_factory.qname('example.com')
```

The `qname` method (i.e. the method that returns a filter for exactly one qname value) is defined as (roughly):

```ruby
def qname(qname)
  ->(message, _protocol = nil) do
    eq_case_insensitive(message.qname, qname)
  end
end
```

If you view the method body from left to right, you will notice the prominent `->` and its corresponding `end` two lines beneath it, which tell you that the value returned by this method is a lambda. The leading underscore is a convention that indicates that the passed value is not used in the lambda.

Notice that the `qname` parameter is effectively stored in the lambda that the method returns?

This technique is called _partial application_, and is extremely useful. Does storing state in the lambda make it any less _functional_? Not really; the state is immutable and used only for comparison.


If we were also to add the requirement that the qtype be 'A' and the protocol be 'TCP', then we could call methods to return those filters as well, and combine them using the `all` compound filter. (Other compound filters are `any` and `none`.) Here is what that would look like:

```ruby
pf = MockDnsServer::PredicateFactory.new
filter = pf.all(
    pf.qtype('A'),
    pf.qname('example.com'),
    pf.from_tcp
)
```

The `all` compound filter is nothing more than a simple wrapper around Ruby's Enumerable's `all?` method:

```ruby
  def all(*predicates)
    ->(message, protocol = nil) do
      predicates.all? { |p| p.call(message, protocol) }
    end
  end
```

How can this work? The filters are interchangeable because they all take the same parameter list and they all return a value usable by the caller. To be specific, they are passed the message that was received, and the protocol with which it was sent, and return a boolean value. We've already seen one example, the lambda returned by the `qname` method shown above. Here is another one; this one returns true if and only if the message was sent over TCP:

```ruby
def from_tcp
  ->(_message, protocol) { protocol == :tcp }
end
```

In this case, we only care about the protocol so we can ignore the first (`message`) parameter.

----

### Conclusion

I hope I have been successful in persuading you to consider using callables for implementing variable predicates and actions.

These are just two examples. I will stop here for the sake of brevity, but if you have any questions or suggestions for elaboration, please contact me. I am keithrbennett on Twitter, Github, and several other sites.

----

### Footnotes

(1) Polymorphism by inheritance is a key characteristic of object oriented design whereby, by virtue of having a common ancestor in the class hierarchy that contains the method in question, objects of different classes can respond to the same message (typically identified by a method or function name) differently. This can be a nice design in some cases, but in others it is an overly heavy handed solution to a simple problem, as it forces the developer to create multiple classes in a class hierarchy.


(2) To be more precise, Ruby supports polymorphism by inheritance, but not by checking the class hierarchy like most OO languages do. Instead, it is using duck typing, and merely calls the method by name; since a subclass will be able to call its superclass' method by default, it works.
