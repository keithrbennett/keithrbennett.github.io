---
title: Using Lambdas to Simplify Your Code
date: 2018-07-16
---

### Using Lambdas in Object Oriented Languages

[Lambdas](https://en.wikipedia.org/wiki/Anonymous_function), which are self contained functions, are best known in the context of [functional programming](https://en.wikipedia.org/wiki/Functional_languages) languages. However, even [object oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) languages that support lambdas, such as Ruby, can greatly benefit from their use.

After I started using lambdas, I realized that, in procedural and object oriented languages, support for customizable logic is awkward, and in the case of large numbers of variations in customizable logic, altogether absent.
 
 The procedural `if-elsif-elsif-end` or `case` clauses work when you have a small number of conditions and actions that are known in advance, but if you don't, they're pretty useless.

The object oriented approach of [polymorphism](https://en.wikipedia.org/wiki/Polymorphism_(computer_science)) isn't much better.
Polymorphism is a key characteristic of object oriented design whereby objects of different classes can respond to the same message (usually via a method or function name) differently. This can be a nice design when the response to that message is the only thing that differs, and when the different implementations are nontrivial, but in other cases it is an overly heavy handed solution to a simple problem.

As far as I can tell, both cases become unusable when there you need complex behaviors that are not known until runtime.

For example, what if we have an object of a class that contains three varying behaviors, and each of these behaviors has five possible strategies. If we were to write a class to implement each possible variation of the three behaviors, we would have to hard code the behaviors into the [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product) of the three sets, 5 * 5 * 5, or 125 classes!

Anyway, for simple behaviors, the burden and ceremony of one class per behavior is excessive in both cognitive load and verbosity. Furthermore, it is an arbitrary choice of one of many criteria that might reasonably be used to set class boundaries.

A better solution is using callables such as lambdas.

----

#### Callables as a Superset of Lambdas

In traditional object oriented languages such as Java and C++, polymorphism is (in general) implemented by inheritance. Ruby does that also, but in addition, Ruby uses _duck typing_, meaning that _any_ object that responds to the method name can be used. This means that in Ruby, any object that responds to `call` can be in place of a lambda. It could be a lambda, an instance of a class, or even a class or module itself, as long as it has a `call` method. This provides great flexibility in implementing varying behavior. You can choose what kind of object to use based on your situation. For complex behaviors you may want modules or classes, and for simpler behaviors a lambda will work just fine.

 Since any object responding to `call` can be used in place of a lambda, I will use the term _callable_ instead of _lambda_ where applicable.

----

### The Buffered Enumerable

I once worked on a project where I needed to implement buffering on multiple kinds of things received over a network connection. I started writing the first one, and noticed how the code could be cleanly divided into two kinds of tasks: 1) knowing _when_ to fetch objects into the buffer and other buffer management tasks, and 2) _how_ to fetch each block of objects and what _else_ to do each time that fetch is performed (e.g. logging, displaying a message to the user, updating some external state).

Realizing that #1 would be common and identical to all cases, and only #2 would vary, I thought about how wasteful it would be to implement #1 separately in all cases. I thought about the admonition about high cohesion / low coupling, and the Unix axiom "do one thing well", and decided to separate the two. The most natural way to design this functionality in Ruby is with an `Enumerable`; it can be used to call a myriad of useful methods, or easily used to generate an array by calling its `to_a` method. Thus was born the [`BufferedEnumerable`](https://github.com/keithrbennett/trick_bag/blob/master/lib/trick_bag/enumerables/buffered_enumerable.rb) class in my [`trick_bag`](https://github.com/keithrbennett/trick_bag/) gem.

The BufferedEnumerable class manages buffering but has no idea how to fetch chunks of data, nor what else to do at each such fetch; for that, the caller provides callables such as lambdas. (Upon user request, the ability to subclass it with named methods for this was also added.) The result is a superb simplification, where the logic of buffering is defined in only one place, and the places it is used need not be concerned with its implementation (or its testing!).

To create an instance of this with callables, we call the `BufferedEnumerable` class method `create_with_callables`, which is defined as follows:

```ruby
 def self.create_with_callables(chunk_size, fetcher, fetch_notifier = nil)
    instance = self.new(chunk_size)
    instance.fetcher = fetcher
    instance.fetch_notifier = fetch_notifier
    instance
  end
```

If a fetcher callable has been defined, it is called as shown below whenever the buffer needs to be filled, with the emptied data buffer and the number of objects requested passed as parameters:

```ruby
fetcher.(data, chunk_size)
```

Here is a trivial fetcher that merely fills the array of the requested chunk size with random numbers:

```ruby
fetcher = ->(data, chunk_size) do
  chunk_size.times { data << Random.rand }
end
```

Here is a `pry` example that illustrates the call to the fetcher, and its effect on the passed array:

```
[7] pry("")> a = []; fetcher.(a, 2)
2
[8] pry("")> a
[
    [0] 0.4885287976297428,
    [1] 0.5493143769524284
]
````

(In Ruby, `.(` is an abbreviation for `.call(`.)

After the buffer is filled, if a fetch notifier callable has been defined, it too is called, with the data buffer:


```ruby
fetch_notifier.(data)
```

A trivial fetch notifier might look like this:

```ruby
->(data) { puts "#{Time.now} Fetched #{data.size} objects" } 
```

(`data.size` will usually differ from `chunk_size` on the last fetch.)

After defining the `fetcher` and `fetch_notifier` lambdas, we could call the class method shown above as follows:

```ruby
buffered_enumerable = BufferedEnumerable.create_with_callables( \
    1000, fetcher, fetch_notifier)
```

By parameterizing the behaviors with callables, we have increased the simplicity of the implementation by separating the two orthogonal tasks into separate code areas.

----

### Using Predicate Callables to Implement Filters

_Predicates_ are functions that return a Boolean value, that is, either true or false. There are many applications of predicates in software; filters, boundaries, triggers, authentication results...basically, anything that involves a true or false value.

Configurable predicates are another natural fit for callables.

I once had to write a [generic DNS mock server](https://github.com/keithrbennett/mock_dns_server) for network testing  that could be configured to respond with specific behaviors based on the characteristics of the incoming request. In another situation more recently, I was writing some accounting software and wanted to be able to filter the working set of transactions based on date, category, etc.

Both cases were an excellent fit for using callables as filters.

In the case of the mock DNS server, there were multiple criteria for the filters, such as protocol (TCP vs. UDP), qtype (question type), qclass (question class), and qname (question name). I provided methods that return lambdas that filter for specific values for those attributes; for example, for a filter that will return true only for the qname `example.com`, you would do the following:

```ruby
predicate_factory = MockDnsServer::PredicateFactory.new
filter = predicate_factory.qname('example.com')
```

If we were also to add the requirement that the qtype be 'A' and the protocol be 'TCP', then we could call methods to return those filters and combine them using the _all_ compound filter. (Other compound filters are _any_ and _none_.) Here is what that would look like:


```ruby
pf = MockDnsServer::PredicateFactory.new
filter = pf.all(
    pf.qtype('A'),
    pf.qname('example.com'),
    pf.from_tcp
)
```

How can this work? The filters are interchangeable because they all share the same method signature. They are passed the message that was received, and the protocol with which it was sent, and return a boolean value. For example, here is the implementation of `from_tcp`:

```ruby
def from_tcp
  ->(_, protocol) { protocol == :tcp }
end
```

In this case, we only care about the protocol so we can ignore the first (`message`) parameter.

By the way, the `all` compound filter is nothing more than a simple wrapper around Ruby's Enumerable's `all?` method:

```ruby
  def all(*predicates)
    ->(message, protocol = nil) do
      predicates.all? { |p| p.call(message, protocol) }
    end
  end
```

The `qname` method (i.e. the method that returns a filter for exactly one qname value) is defined as (roughly):

```ruby
def qname(qname)
  ->(message, _ = nil) do
    eq_case_insensitive(mt(message).qname, qname)
  end
end
```

Notice that the `qname` parameter is effectively stored in the lambda that the method returns?

This technique is called _partial application_, and is extremely useful. Does storing state in the lambda make it any less _functional_? Not really; the state is immutable and used only for comparison.

----

### Conclusion

I hope I have been successful in persuading you to consider using callables for implementing variable predicates and actions.

These are just two examples. I will stop here for the sake of brevity, but if you have any questions or suggestions for elaboration, please contact me. I am keithrbennett on Twitter and several other sites.