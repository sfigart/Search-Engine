class Posting
  include MongoMapper::Document

  key :term, String
  key :docid, String
  key :freq, Integer
  key :locations, String
  key :tfidf, Float
  key :weight, Float

  timestamps!
end
