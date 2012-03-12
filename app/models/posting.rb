class Posting
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  key :term, String
  key :docid, String
  key :freq, Integer
  key :locations, String
  key :tfidf, Float
  key :weight, Float
  key :excerpts, Array

  timestamps!

  belongs_to :dictionary
  belongs_to :page
end
