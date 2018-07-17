---
title: Using Lambdas to Simplify Your Code
date: 2018-07-16
---

### Using Lambdas in Object Oriented Languages

[Lambdas](https://en.wikipedia.org/wiki/Anonymous_function), which are self contained functions, are best known in the context of [functional programming](https://en.wikipedia.org/wiki/Functional_languages) languages. However, even [object oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) languages that support lambdas, such as Ruby, can greatly benefit from their use in some cases.

After I started using lambdas, I realized that logic parameterization in object oriented languages is super awkward, with their convention of using `if-elsif-elsif-end` or `case` clauses.

[Polymorphism](https://en.wikipedia.org/wiki/Polymorphism_(computer_science)) is an object oriented design paradigm that is intended to address this need, but using a class hierarchy to implement varying behavior in many cases is an overly heavy handed solution to a simple problem.

For example, what if we have an object of a class that contains three varying behaviors, and each of these behaviors has five possible strategies. If we were to write a class to implement each possible combination of the three behaviors, we would have to hard code the behaviors into the [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product) of the three sets, 5 * 5 * 5, or 125 classes!

Anyway, for simple behaviors, the burden and ceremony of one class per behavior is excessive in both cognitive load and verbosity. Furthermore, it is an arbitrary choice of one of many criteria that might reasonably be used to define class boundaries.

#### Duck Typing in Ruby Enables Callables as a Superset of Lambdas

In Ruby, thanks to duck typing, _any_ object that responds to the `call` method can be used in place of a lambda...so that call could be a method on an instance of any class, or even the class itself. This provides great flexibility in implementing varying behavior. Since any object responding to `call` can be used in place of a lambda, I will use the term _callable_ instead of _lambda_ where applicable.

----

### The Buffered Enumerable

I once worked on a project where I needed to implement buffering on multiple kinds of things received over a network connection. I started writing the first one, and noticed how the code could be cleanly divided into two kinds of tasks: 1) knowing when to fill the buffer and other buffer management tasks, and 2) how to fetch each block of objects and what else to do when performing that (e.g. logging, displaying a message to the user, updating some external state).

I thought about the multiple times I would need to implement this buffering, the admonition about high cohesion / low coupling, and the Unix axiom "do one thing well", and decided to separate the two. From this was born the [`BufferedEnumerable`](https://github.com/keithrbennett/trick_bag/blob/master/lib/trick_bag/enumerables/buffered_enumerable.rb) class in my [`trick_bag`](https://github.com/keithrbennett/trick_bag/) gem.

The BufferedEnumerable class manages buffering but has no idea how to fetch chunks of data, nor what else to do at each such fetch; for that, the caller provides callables such as lambdas. (Upon user request, the ability to subclass it with named methods for this was also added.) The result is a superb simplification, where the logic of buffering is defined in only one place, and the places it is used need not be concerned with its implementation (or its testing!).

To create an instance of this with callables, we call the `BufferedEnumerable` class method, which is defined as follows:

```ruby
 def self.create_with_callables(chunk_size, fetcher, fetch_notifier = nil)
    instance = self.new(chunk_size)
    instance.fetcher = fetcher
    instance.fetch_notifier = fetch_notifier
    instance
  end
```

If a fetcher callable has been defined, it is called like this whenever the buffer needs to be filled, with the data buffer and the number of objects requested passed as parameters:

```ruby
fetcher.(data, chunk_size)
```

Here is a trivial fetcher that merely fills the array of the requested chunk size with random numbers:

```ruby
fetcher = ->(data, chunk_size) do
  chunk_size.times { data << Random.rand }
end
```

(`data` is an array that, for every fetcher invocation, is cleared and passed to the fetcher to be filled with objects.)

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

After defining the `fetcher` and `fetch_notifier` lambda, we could call the class method shown above as follows:

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

In the case of the mock DNS server, there were multiple criteria for the filters, such as TCP vs. UDP, qtype (question type), qclass (question class), and qname (question name). So there are methods that return lambdas that filter for specific values for those attributes; for example, for a filter that will return true only for the qname `example.com`, you would make this call:

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

How can this work? Because these methods all have the same method signature. They are passed the message that was received, and the protocol with which it was sent, and return a boolean value. For example, here is the implementation of `from_tcp`:

```ruby
def from_tcp
  ->(_, protocol) { protocol == :tcp }
end
```

In this case, we can ignore the first (`message`) parameter.

By the way, the `all` compound filter is nothing more than a simple wrapper around Ruby's Enumerable's `all?` method:

```ruby
  def all(*predicates)
    ->(message, protocol = nil) do
      predicates.all? { |p| p.call(message, protocol) }
    end
  end
```

The `qname` method is defined as (roughly):

```ruby
def qname(qname)
  ->(message, _ = nil) do
    eq_case_insensitive(mt(message).qname, qname)
  end
end
```

Notice that the `qname` parameter is effectively stored in the lambda that the method returns?

This technique is called _partial application_, and is extremely useful. Does storing state in the lambda make it any less _functional_? Not really; the state is immutable and used only for comparison.

