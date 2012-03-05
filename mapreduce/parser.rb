#!/usr/bin/env /Users/sfigart/.rvm/rubies/ruby-1.9.3-p125/bin/ruby
require 'rubygems'

ENV['GEM_PATH'] = "/Users/sfigart/.rvm/gems/ruby-1.9.3-p125@rails-3.2.2:/Users/sfigart/.rvm/gems/ruby-1.9.3-p125@global"
Gem.clear_paths

require 'wukong'
require 'mongo_mapper'
require 'inverted_index'

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
class LinkMapper < Wukong::Streamer::LineStreamer
  def process docid

    MongoMapper.connection = Mongo::Connection.new('localhost')
    MongoMapper.database = 'search_engine_development'

    # Get html
    page = Page.first(:docid => docid)

    parser = InvertedIndex::Parse.new(page.html)
    
    yield [doc.docid, 1]
  end
end

class LinkReducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :key_count
  def start! *args
    @key_count = 0
  end

  def accumulate(link, count)
    self.key_count += count.to_i
  end

  def finalize
    yield [ key, key_count ]
  end
end

Wukong::Script.new(LinkMapper, nil).run
