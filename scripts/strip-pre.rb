#!/usr/bin/env ruby

require 'nokogiri'
require 'trick_bag'


LANGUAGE = begin
  if ARGV[0].nil?
    nil
  else
    case ARGV[0][0].downcase
      when 'r'
        'ruby'
      when 'j'
        'java'
      when 'c'
        'clojure'
      else
        ''
    end
  end
end


def transform(s)
  text = Nokogiri::HTML(s).xpath('html/body/pre').text
  "```#{LANGUAGE}\n" + CGI.unescapeHTML(text) + "```\n"
end


def output_results(input, output)

  separator_line = "#{'-' * 79}\n"

  sandwich = ->(s) do
    '' << separator_line << s.chomp << "\n" << separator_line
  end

  puts separator_line
  puts "Input:\n#{sandwich.(input)}"
  puts "Output:\n#{sandwich.(output)}"
end


def copy_result_to_clipboard(result)
  TrickBag::Io::TempFiles.file_containing(result) do |temp_filespec|
    `cat #{temp_filespec} | pbcopy`
  end
end


input = `pbpaste`
output = transform(input)
output_results(input, output)
copy_result_to_clipboard(output)

=begin

Example:

-------------------------------------------------------------------------------
Input:
-------------------------------------------------------------------------------
<pre class="brush: ruby; title: ; notranslate" title="">def stringified_key_hash(numbers)
  numbers.each_with_object({}) do |n, hsh|
    hsh[n] = n.to_s
  end
end
</pre>
-------------------------------------------------------------------------------
Output:
-------------------------------------------------------------------------------
```ruby
def stringified_key_hash(numbers)
  numbers.each_with_object({}) do |n, hsh|
    hsh[n] = n.to_s
  end
end
```
-------------------------------------------------------------------------------

=end
