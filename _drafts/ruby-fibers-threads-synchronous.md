---
title: Fiber, Thread, and Synchronous HTTP Requests in Ruby
date: 2024-09-07
---



I have a web site containing many web links, and wanted to write a rake task to report any that could not be accessed. 

### The Synchronous Approach



I started out the conventional way, using `Net::HTTP.get(URI(url))`, but it became clear to me that it was taking way longer than it needed to.



For simplicity sake I will post code that just gets the same URL _n_ times:



```ruby
  def get_responses_synchrously(count)
    logger.debug("Getting #{count} responses synchronously")
    count.times.with_object([]) { |_n, responses| responses << Net::HTTP.get(URI(url)) }
  end
```

### The Thread Approach

Having been a fan of threads for a long time, I then tried doing it with threads. Since the number of links was just a few dozen, this number was low enough that creating a thread for each link was feasible:



```ruby
  def get_responses_using_threads(count)
    logger.debug("Getting #{count} responses using threads")
    uri = URI(url)
    threads = Array.new(count) { Thread.new { Net::HTTP.get(uri) } }
    threads.map(&:value)
  end
```

As you can guess, this was *way* faster.

### The Fiber Approach

I wasn't done though -- recently I _finally_ got around to learning about Ruby fibers, and wanted to try them here. Rather than write the low level Fiber code myself, it was simpler to use @ioquatix's (Samuel Williams') excellent `async` Ruby gems (I needed `async` and `async-http`) to do the heavy lifting. The resulting code was more complex than the previous two approaches, but not too bad:



```ruby
  def get_responses_using_fibers(count)
    logger.debug("Getting #{count} responses using fibers")
    responses = []
    Async do
      begin
        internet = Async::HTTP::Internet.new(connection_limit: 65536)
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



### Comparing the Performance Results

I did a benchmark to compare the results of fetching request counts for powers of 2 from 1 to 256 (`[1, 2, 4, 8, 16, 32, 64, 128, 256]`).

Here are the results comparing all three approaches:



As expected, the synchronous approach was by far the slowest, since only one request could be active at any given time. Both the thread and fiber approach were dramatically faster, and not that different from each other. What do we make of this though? Which should we choose to use?

### Fibers vs. Threads

If one knows that the numbers will always fall within the bounds of 1 to 256, then it probably doesn't much matter which to use. However, if there is a possibility of higher request counts, then fibers make more sense:

**Threads:**

- **OS-Managed:** Threads are managed by the operating system. Each thread has its own dedicated stack and other resources allocated by the OS.
- **Context Switching Overhead:** Switching between threads involves saving and restoring the entire execution context (registers, stack pointers, etc.), which is a relatively expensive operation.
- **System Limits:** The operating system typically imposes limits on the number of threads a process can create due to resource constraints.

**Fibers:**

- **User-Level:** Fibers are a user-level construct managed entirely within the Ruby interpreter. They share the same stack and other resources with the thread they're running in.
- **Cooperative Scheduling:** Fibers explicitly yield control to each other, making context switching much faster and less resource-intensive.
- **Lightweight:** Due to their cooperative nature and shared resources, fibers have a much smaller memory footprint than threads.



### Higher Request Counts

Even with as few as 256 simultaneous requests, the OS' file handle limit may be exceeded. If you get an error saying that all the process' file handles have been used, you can use `ulimit` to increase that maximum file handle count, and then rerun the program. For example: `ulimit -n 2048 && my-program`.

When increasing the simultaneous request count, the maximum thread count will be reached long before the maximum fiber count. One possible maximum is 1,000 threads. When a count exceeds the maximum, it is necessary to do some kind of thread pooling or queueing scheme to use each thread for more than one request.




