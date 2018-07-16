---
title: Using Lambdas to Simplify Your Code
date: 2018-07-16
---

[Lambdas](https://en.wikipedia.org/wiki/Anonymous_function), which are self contained functions, are best known in the context of [functional programming](https://en.wikipedia.org/wiki/Functional_languages) languages. However, even [object oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) languages such as Ruby can greatly benefit from their use in some cases.

After I started using lambdas, I realized that logic parameterization in object oriented languages is super awkward, with their convention of using `if-elsif-elsif-end` or `case` clauses.

[Polymorphism](https://en.wikipedia.org/wiki/Polymorphism_(computer_science)) in object oriented programming is intended to address this need, but using a class hierarchy to implement varying behavior in many cases is an overly heavy handed solution to a simple problem.

For example, what if we have an object of a class that contains three varying behaviors, and each of these behaviors has five possible strategies. If we were to write a class to implement each combination of the three behaviors, we would have to hard code the behaviors into 5 * 5 * 5, or 125 classes!

Anyway, for simple behaviors, the burden and ceremony of one class per behavior is excessive in both cognitive load and verbosity. Furthermore, it is an arbitrary choice of one of many criteria that might logically be used to define class boundaries.

In Ruby, thanks to duck typing, _any_ object that responds to the `call` method can be used in place of a lambda...so that call could be a method on an instance of any class, or even the class itself. This provides great flexibility in implementing varying behavior. For this reason, I will use the term _callable_ instead of _lambda_ where applicable.

### Example 1: The Buffered Enumerable

I onced worked on some code where I needed to implement buffering on multiple kinds of things received over a network connection. I started writing the first one, and noticed how there were two things going on -- 1) knowing when to fill the buffer and other buffer management tasks, and 2) how to fetch each block of objects and what else to do when performing that (e.g. logging, displaying a message to the user, updating some external state).

I thought about the multiple times I would need to implement this buffering, the admonition about high cohesion / low coupling, and the Unix axiom "do one thing well", and decided to separate the two. From this was born the [`BufferedEnumerable`](https://github.com/keithrbennett/trick_bag/blob/master/lib/trick_bag/enumerables/buffered_enumerable.rb) in my [`trick_bag`](https://github.com/keithrbennett/trick_bag/) gem.

This class manages buffering but has no idea how to fetch chunks of data, nor what else to do at each such fetch; for that, the caller provides lambdas. (Upon user request, the ability to subclass it with named methods for this was also added.) The result is a superb simplification, where the logic of buffering is defined in only one place, and the places it is used need not be concerned with its implementation (or its testing!).

To create an instance of this with callables, we call the `BufferedEnumerable` class method, which is defined as follows:

```ruby
 def self.create_with_lambdas(chunk_size, fetcher, fetch_notifier = nil)
    instance = self.new(chunk_size)
    instance.fetcher = fetcher
    instance.fetch_notifier = fetch_notifier
    instance
  end
```

If a fetcher callable has been defined, it is called like this, with the data buffer and the number of objects requested, whenever the buffer needs to be filled:

```ruby
fetcher.(data, chunk_size)
```

Here is a trivial fetcher that merely fills the array of the requested chunk size with random numbers:

```ruby
fetcher = ->(data, chunk_size) do
  chunk_size.times { data << Random.rand }
end
```

And here is some code that calls it:

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

By parameterizing the behaviors with callables, we have increased the simplicity of the implementation by separating the two orthogonal tasks into separate code areas.


### Predicates

_Predicates_ are functions that return a Boolean value, that is, either true or false. There are many applications of predicates in software; filters, boundaries, triggers, authentication...basically, anything that involves a true or false value.

Varying predicates are another natural fit for callables.


### Example 2: Predicate Example: Filtering

I once had to write a generic DNS mock server for network testing that could be configured to respond with specific behaviors based on the characteristics of the incoming request. In another situation more recently, I was writing some accounting software and wanted to be able to filter the working set of transactions based on date, category, etc.

Both cases were an excellent fit for using callables as filters.

In the case of the mock DNS server, there were multiple criteria for the filters, such as TCP vs. UDP, qtype (question type), qclass (question class), qname and (question name). So there are methods that return lambdas for specific values for those characteristics; for example, for a filter that will return true only for the qname `example.com`, you would make this call:

```ruby
predicate_factory = MockDnsServer::PredicateFactory.new
filter = predicate_factory.qname('example.com')
```

If we were also to add the requirement that the qtype be 'A' and the protocol be 'TCP', then we could call methods to return those filters. Combining them into a compound filter is a simple matter of calling the compound filter (all, any, or none), and combine them in a compound filter that requires all passed filters to be true:

```ruby
pf = MockDnsServer::PredicateFactory.new
filter = pf.all(
    pf.qtype('A'),
    pf.qname('example.com'),
    pf.from_tcp
)
```

How can this work? Because these methods all have the same method signature. They are passed the message that was received, and the protocol with which it was sent. For example, here is the implementation of `from_tcp`:

```ruby
def from_tcp
  ->(_, protocol) { protocol == :tcp }
end
```

In this case, we can ignore the first (`message`) parameter.

The `all` compound filter is a simple wrapper around Ruby's Enumerable's `all?` method:

```ruby
  def all(*predicates)
    ->(message, protocol = nil) do
      predicates.all? { |p| p.call(message, protocol) }
    end
  end
```

This all works because of _partial application_, which means that you can partially apply the data to the lambda (effectively embed some of the data in the lambda) if that data is in scope (more precisely, in its binding) when the lambda is created. In the `all` method above, the lambda will always have access to the `predicates` passed to it, even if after it is returned from the `all` method it is passed all over the program.