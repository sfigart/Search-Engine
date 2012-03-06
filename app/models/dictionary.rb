class Dictionary
  include MongoMapper::Document

  key :term, String
  key :doc_count, Integer
  key :tot_freq, Integer
  key :idf, Float

  timestamps!

  many :postings
end
