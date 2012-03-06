#!/usr/bin/env /Users/sfigart/.rvm/rubies/ruby-1.9.3-p125/bin/ruby
require 'rubygems'

ENV['GEM_PATH'] = "/Users/sfigart/.rvm/gems/ruby-1.9.3-p125:/Users/sfigart/.rvm/gems/ruby-1.9.3-p125@global"
Gem.clear_paths

require 'wukong'

class TermDocFreq < Struct.new(:term, :docid, :frequency, :locations)
end

# /dictionary.rb --run=local ./term_doc_freq.txt dictionary.txt
class DictionaryMapper < Wukong::Streamer::StructStreamer
  def process record, *args
    case record
      when TermDocFreq
        yield [record.term, record.docid, record.frequency, record.locations]
    end
  end
end


class DictionaryReducer < Wukong::Streamer::AccumulatingReducer
  def start! term, docid, frequency, locations
    @doc_count = 0
    @tot_freq = 0
  end

  # For every term and docid calculate frequency and index
  def accumulate term, docid, frequency, index
    @doc_count += 1
    @tot_freq += frequency.to_i
  end

  def finalize
    yield [ key, @doc_count, @tot_freq ]
  end
end

#Wukong::Script.new(DictionaryMapper, DictionaryReducer).run
Wukong::Script.new(DictionaryMapper,
                   DictionaryReducer).run
