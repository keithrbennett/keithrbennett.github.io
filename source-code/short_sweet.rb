#!/usr/bin/env ruby

# Companion source code to blog article at:
# https://bbs-software.com/blog/2019/11/13/enumerables-short-and-sweet.html

require 'yaml'

def filtered_and_transformed_records_1(records)
  results = []

  records.each do |record|
    next unless record.vowel?
    results << [record.letter, record.frequency]
  end

  results
end


def filtered_and_transformed_records_2(records)
  records.each_with_object([]) do |record, results|
    next unless record.vowel?
    results << [record.letter, record.frequency]
  end
end


def filtered_and_transformed_records_3(records)
  records.select(&:vowel?).each_with_object([]) do |record, results|
    results << [record.letter, record.frequency]
  end
end


def filtered_and_transformed_records_4(records)
  records.select(&:vowel?).map { |record| [record.letter, record.frequency] }
end

LetterFrequency = Struct.new(:letter, :frequency, :vowel?)

RECORDS = [
    LetterFrequency.new('a', 15, true),
    LetterFrequency.new('b', 4, false),
    LetterFrequency.new('c', 7, false),
    LetterFrequency.new('d', 6, false),
    LetterFrequency.new('e', 32, true),
    LetterFrequency.new('f', 3, false),
    LetterFrequency.new('i', 18, true),
    LetterFrequency.new('o', 19, true),
    LetterFrequency.new('u', 4, true),
    LetterFrequency.new('z', 0, false),
]

a1 = filtered_and_transformed_records_1(RECORDS)
a2 = filtered_and_transformed_records_2(RECORDS)
a3 = filtered_and_transformed_records_3(RECORDS)
a4 = filtered_and_transformed_records_4(RECORDS)

all_equal = [a2, a3, a4].all? { |a| a == a1 }

if all_equal
  puts "All arrays were equal:\n\n#{a1.to_yaml}"
else
  raise "Error; arrays were not equal."
end