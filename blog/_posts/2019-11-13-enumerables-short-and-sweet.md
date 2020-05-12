---
title: Ruby Enumerables Make Your Code Short and Sweet
tags: ruby, enumerable, functional
canonical_url: https://blog.bbs-software.com/blog/2019/11/13/enumerables-short-and-sweet.html
---

One of the most amazing things about Ruby is the richness of its `Enumerable` library; there are _so many_ things it can do. Another is Ruby's ability to express intent with the utmost conciseness and clarity. However, out in the wild I very often see code that fails to take full advantage of these qualities.
 
As a contrived example, let's say we're keeping track of letter frequencies in a document. We define a class to contain them as:

```ruby
LetterFrequency = Struct.new(:letter, :frequency, :vowel?)
```

I've seen a lot code that looks like this:

```ruby
def filtered_and_transformed_records_1(records)
  results = []

  records.each do |record|
    next unless record.vowel?
    results << [record.letter, record.frequency]
  end

  results
end
```

In more primitive languages one must use these approaches, but in Ruby we have some major refactorings that can make this code much, much simpler.

First, we can use `each_with_object` to eliminate the need for the explicit initialization of the function-local variable containing the array and its explicit return, on the first and last lines of the method:

```ruby
def filtered_and_transformed_records_2(records)
  records.each_with_object([]) do |record, results|
    next unless record.vowel?
    results << [record.letter, record.frequency]
  end
end
```

I say _function-local_ because we do need the _block-local_ variable `results` inside the `each_with_object` block. However, we've narrowed the scope of the `results` variable, and that's always a good thing.

`each_with_object` is like `each` except that it will pass _two_ variables to the block instead of one. In addition to the object from the Enumerable that `each` passes, it passes the object you are using to accumulate results. You initialize the accumulator by passing its initial value to the `each_with_object` method. In this case we are passing a newly created empty array.

`each_with_object`'s return value is the accumulator object, so you don't need to specify the accumulator explicitly for it to be the value returned by the method.

The `each_with_object` usage may not feel natural at first, but once you've seen it a few times your mind will parse it with almost zero effort. (By the way, I always had trouble remembering the order of its arguments until I realized that they were in the same order as in the method name itself; `each` for the enumerated object and `object` for the accumulator object.)

The second refactoring is instead of using control flow constructs like `next`, we can use the `Enumerable` methods `select` or `reject`. We could refactor the code further into:

```ruby
def filtered_and_transformed_records_3(records)
  records.select(&:vowel?).each_with_object([]) do |record, results|
    results << [record.letter, record.frequency]
  end
end
```

After this refactoring, we see the filter where it is more appropriate and helpful. Instead of it being on a line inside the block, it's just a few characters immediately after the input array (`records.select...`).

We've already simplified this method quite a bit, but there's even more we can do. Because `select` returns the filtered array, we can simplify even further by using `map` instead of `each_with_object`!:

```ruby
def filtered_and_transformed_records_4(records)
  records.select(&:vowel?).map { |record| [record.letter, record.frequency] }
end
```

Although as software developers our mission is to deliver functionality, the other side of that coin is to do so as simply as possible. Put otherwise, we need to remove _accidental complexity_ (a.k.a. _incidental complexity_) so that only the _essential complexity_ remains. The functional approaches described here are extremely effective at doing this. We've ended up with a simple one-liner.
 
* * * *

Whenever you start feeling that your code is getting verbose or awkward, ask yourself "could I improve this code with `Enumerable`?" The answer may well be _yes_.

* * * *

For your reference, [here](https://github.com/keithrbennett/keithrbennett.github.io/blob/master/source-code/short_sweet.rb) is a file that contains the methods in the article, and verifies that they all produce the same result.

* * * *

[Note: This article may occasionally be improved. Its commit history is [here](https://github.com/keithrbennett/keithrbennett.github.io/commits/master/blog/_posts/2019-11-13-enumerables-short-and-sweet.md).]
