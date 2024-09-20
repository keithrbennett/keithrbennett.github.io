---
title: Fiber, Thread, and Synchronous HTTP Requests in Ruby
date: 2024-09-20
published: false
---

## Introduction

In this article, we will explore different ways to make HTTP requests in Ruby and compare their performance. We will focus on three approaches: synchronous, threaded, and fiber-based. We will use a simple example of checking the availability of the same URL multiple times.

Why do I care? I have a Ruby on Rails web site containing many links to YouTube song videos, and they are subject to being pulled by their owner or taken down due to copyright issues.I wanted to automate as a rake task the checking of these links for availability, so that I can do the check with minimal effort from time to time. The links are stored in the project in a YAML file, so it's easy to read them into memory. However, how would I check them for accessibility?

To simplify the examples below, instead of fetching the real URL's, I will fetch the same URL multiple times. I'll use a URL built with `"https://httpbin.org/delay/#{sleep_seconds}"` to access the Internet and simulate a nonzero delay. The examples will return an array containing the responses.

### The Synchronous Approach

I started out the simple and conventional way, using `Net::HTTP`:

```ruby
def get_responses_synchrously(count)
  logger.debug("Getting #{count} responses synchronously")
  count.times.with_object([]) do |_n, responses|
    responses << Net::HTTP.get(URI(url))
  end
end
```

However, the time it took was frustratingly long. How could I make this faster?

### The Thread Approach

Having been a fan of threads for a long time, this was the next thing I tried. Since the number of links was just a few dozen, this number was low enough that creating a thread for each link was feasible:

```ruby
def get_responses_using_threads(count)
  logger.debug("Getting #{count} responses using threads")
  threads = Array.new(count) do
    Thread.new { Net::HTTP.get(URI(url)) }
  end
  threads.map(&:value)
end
```

As you can guess, this was *way* faster.

### The Fiber Approach

I wasn't done though -- recently I _finally_ got around to learning about Ruby fibers, and wanted to try them here. Rather than write the low level Fiber code myself, it was simpler to use @ioquatix's (Samuel Williams') excellent `async` Ruby gems (I needed `async` and `async-http`) to handle the low level plumbing. The resulting code was more complex than the previous two approaches, but not too bad (run `gem install async-http` if necessary):

```ruby
def get_responses_using_fibers(count)
  logger.debug("Getting #{count} responses using fibers")
  responses = []
  Async do
    begin
      internet = Async::HTTP::Internet.new(connection_limit: count)
      count.times do
        Async do
          begin
            response = internet.get(url)
            responses << response
          ensure
            response&.finish
          end
        end
      end
    ensure
      internet&.close
    end
  end.wait
  responses
end
```

The magic is in the `Async` framework and `Async::HTTP::Internet`'s `get` method, which is fiber-aware and yields controlf of the CPU while waiting for a response.

### Comparing the Performance Results

I did a benchmark to compare the results of fetching request counts for powers of 2 from 1 to 256 (1, 2, 4, 8, 16, 32, 64, 128, and 256).

Here are the results comparing all three approaches, using the averages of several test runs:

![Synchronous, Threaded, and Fiber-based](/assets/requests-article-fibers-threads-synchronous-graph.png)

To zoom in on the difference between the thread and fiber approach, this graph omits the synchronous approach:

![Threaded and Fiber-based](/assets/requests-article-fibers-threads-graph.png)

As expected, the synchronous approach was by far the slowest, since only one request could be active at any given time. Both the thread and fiber approach were dramatically faster, and not that different from each other. What do we make of this though? Which should we choose to use?

### Fibers vs. Threads

If one knows that the numbers will always fall within the bounds of 1 to 256, then it probably doesn't much matter which to use. However, if there is a possibility of higher request counts, then fibers make more sense. Here are some ways in which threads and fibers differ:

**Threads:**

- **OS-Mapped:** Ruby threads in Ruby 1.9+ are mapped to operating system threads. Each thread has its own dedicated stack and other resources allocated by the OS.
- **Context Switching Overhead:** Switching between threads involves saving and restoring the entire execution context (registers, stack pointers, etc.), which is a relatively expensive operation.
- **System Limits:** The operating system typically imposes limits on the number of threads a process can create due to resource constraints.

**Fibers:**

- **User-Level:** Fibers are a user-level construct managed entirely within the Ruby interpreter. They share the same stack and other resources with the thread they're running in.
- **Cooperative Scheduling:** Fibers explicitly yield control to each other, making context switching much faster and less resource-intensive.
- **Lightweight:** Due to their cooperative nature and shared resources, fibers have a much smaller memory footprint than threads.

### Operating System Open File Limits

In general, the synchronous approach results in only one file handle being used at a time for all the requests. In contrast, the thread and fiber approaches may theoretically have file handles open for all the requests at the same time, since they do not wait for one to finish to start another.

Even with as few as 256 simultaneous requests, the operating system session's file handle limit may be exceeded. If you get an error saying that all the process' file handles have been used, you can use `ulimit` to increase the maximum file handle count for the terminal session, and then rerun the program. For example: `ulimit -n 2048 && my-program`.

However, `ulimit` will only do this successfully if the systemwide maximum file count is large enough to accommodate it.Threads are orders of magnitude more heavyweight than fibers, so for large request counts, fibers will probably work best. Sam Williams posted a YouTube video ([RubyConf Taiwan 2019 - The Journey to One Million by Samuel Williams - YouTube](https://www.youtube.com/watch?v=Dtn9Uudw4Mo)) in which he showed one million fibers running!

### Test Results

I ran multiple suites of tests, where each test computed the duration of `n` requests, where `n` was a power of 2 ranging from 0 to 8 (`[1, 2, 4, 8, 16, 32, 64, 128, 256]`), and then averaged the results. These results then produced the graphs below. The first compares all three approaches, whereas the second compares only fibers and threads.