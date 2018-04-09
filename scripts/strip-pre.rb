#!/usr/bin/env ruby

require 'trick_bag'

SEPARATOR_LINE = "#{'-' * 79}\n"

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


def ellipsize(string, max_length = 60)
  string[0...max_length] << (string.length > max_length ? '...' : '')
end


def sandwich_in_separator_lines(s)
  '' << SEPARATOR_LINE << s.chomp << "\n" << SEPARATOR_LINE
end


def transform(s)
  pos_close_pre_start = s.index('>')
  if pos_close_pre_start.nil?
    raise %Q{> not found in #{ellipsize(s)}}
  end

  s = s[(pos_close_pre_start + 1)..-1]
  s.gsub!('</pre>', '')
  s.chomp!
  "```#{LANGUAGE}\n" + CGI.unescapeHTML(s) + "```\n"
end


input = `pbpaste`
puts SEPARATOR_LINE
puts "Input:\n#{sandwich_in_separator_lines(input)}"
output = transform(input)
puts "Output:\n#{sandwich_in_separator_lines(output)}"

TrickBag::Io::TempFiles.file_containing(output) do |temp_filespec|
  `cat #{temp_filespec} | pbcopy`
end
