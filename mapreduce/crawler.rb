#!/usr/bin/env /Users/sfigart/.rvm/rubies/ruby-1.9.3-p125/bin/ruby
require 'rubygems'

ENV['GEM_PATH'] = "/Users/sfigart/.rvm/gems/ruby-1.9.3-p125:/Users/sfigart/.rvm/gems/ruby-1.9.3-p125@global"
Gem.clear_paths

require 'digest/sha1'
require 'wukong'
require 'mechanize'
require 'mongo_mapper'

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

# /crawler.rb --run=local ./to_crawl.txt out
class LinkMapper < Wukong::Streamer::LineStreamer
  def process line
    File.open('test_mapper.txt', 'a') {|f| f.write(line) }
    begin
      page, links = get_links(line)
      unless page.nil?
        # Update Page in db
        save_page_body(page, line)

        links.each do |link|
          yield [link, 1]
        end
      end
    rescue Exception
    end
  end

  def save_page_body(page, url)
    MongoMapper.connection = Mongo::Connection.new('localhost')
    MongoMapper.database = 'search_engine_development'
    page_db = Page.first(:url => url)

    page_db.html = page.body
    page_db.docid = Digest::SHA1.hexdigest(url)
    page_db.visited = true
    page_db.last_visited = Time.now.utc
    page_db.save
  end

  def get_links(url)
    agent = Mechanize.new
    page = agent.get(url)
    base_url = page.uri.to_s.gsub(/\/$/,'') # Remove the trailing slash
    links = []
    page.links.each_with_index do |link, index|
      # Skip empty links
      next if link.uri.nil?

      # Skip javascript
      next if link.uri.to_s =~ /javascript/

      # Skip ad sites
      next if is_ad?(link.uri.to_s)

      # Normalize relative urls
      absolute = normalize_link(link, base_url)

      # links[absolute] = [absolute, link.text] unless links.has_key?(absolute)
      
      links << absolute
    end
    return page, links
  end

  def is_ad?(url)
    ad_sites = [ 'http://yellowpages', 'http://ad.doubleclick', 'https://www.surveymonkey', ]
    ad_sites.any? {|w| url =~ /#{w}/}
  end

  def normalize_link(link, base_url)
    url = link.uri.to_s
    # for relative urls
    url =~ /^\// ? base_url + url : url
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

Wukong::Script.new(LinkMapper, LinkReducer).run
