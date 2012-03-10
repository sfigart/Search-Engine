#!/usr/bin/env /Users/sfigart/.rvm/rubies/ruby-1.9.3-p125/bin/ruby
require 'rubygems'

ENV['GEM_PATH'] = "/Users/sfigart/.rvm/gems/ruby-1.9.3-p125:/Users/sfigart/.rvm/gems/ruby-1.9.3-p125@global"
Gem.clear_paths

require 'wukong'
require 'mongo_mapper'
require 'inverted_index'
require 'stemmify'

class Page
  include MongoMapper::Document

  key :docid, String
  key :name, String
  key :url, String
  key :visited, Boolean
  key :last_visited, Date
  key :last_visited_status_code
  key :html, String

  timestamps!
end

# /parser.rb --run=local ./to_parse.txt out
class ParseMapper < Wukong::Streamer::LineStreamer
  def process docid

    MongoMapper.connection = Mongo::Connection.new('localhost')
    MongoMapper.database = 'search_engine_development'

    # Parse html
    page = Page.first(:docid => docid)

    parser = InvertedIndex::Parse.new(page.html)
    parser.parse
    tokens = InvertedIndex::Cleaner.clean(parser.tokens, parser.text)

    # Yield
    tokens.each_with_index do |token, index|
      yield [token.downcase, page.docid, index]
    end
  end
end

class ParseReducer < Wukong::Streamer::AccumulatingReducer
  # Process with this key
  def get_key term, docid, index
    [term, docid]
  end

  def start! term, docid, index
    @frequency = 0
    @positions = []
  end

  # For every term and docid calculate frequency and index
  def accumulate term, docid, index
    @frequency += 1
    @positions << index
  end

  # Prefix with term_doc_freq so dictionary job can use struct streamer
  def finalize
    yield [ "term_doc_freq", key, @frequency, @positions.join("^") ]
  end
end

# Need to partition AND SORT !!! using term, docid
# partition to keep same keys on same reducer
# sort to sort by more than the first value
Wukong::Script.new(ParseMapper,
                   ParseReducer,
                   :partition_fields => 2,
                   :sort_fields => 2).run
