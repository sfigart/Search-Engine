# REMEMBER TO UPDATE ./mapreduce/crawler.rb definition if you
# change this substantially
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

  # Returns all models where visited is not true
  def self.not_visited
    Page.all(:visited => [false, nil])
  end

  def visit
  end
end
