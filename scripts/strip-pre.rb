#!/usr/bin/env ruby

require 'shellwords'
require 'trick_bag'

LANGUAGE = (ARGV[0] && ARGV[0][0] == 'r') ? 'ruby' : ''

def ellipsize(string, max_length = 60)
  string[0...max_length] << (string.length > max_length ? '...' : '')
end


def sandwich_in_separator_lines(s)
  sep_line = "#{'-' * 79}\n"
  sep_line + s.chomp + "\n" + sep_line
end


def transform(s)
  pos_close_pre_start = s.index('>')
  if pos_close_pre_start.nil?
    raise %Q{> not found in #{ellipsize(s)}}
  end

  s = s[pos_close_pre_start..-1]
  s.gsub!('</pre>', '')
  s.chomp!
  "```#{LANGUAGE}\n" + CGI.unescapeHTML(s) + "```\n"
end


input = `pbpaste`
puts "Input:\n#{sandwich_in_separator_lines(input)}"
output = transform(input)
puts "Output:\n#{sandwich_in_separator_lines(output)}"

TrickBag::Io::TempFiles.file_containing(output) do |temp_filespec|
  `cat #{temp_filespec} | pbcopy`
end

