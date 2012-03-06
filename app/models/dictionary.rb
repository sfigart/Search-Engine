class Dictionary
  include MongoMapper::Document

  key :term, String
  key :doc_count, Integer
  key :tot_freq, Integer
  key :idf, Float

  timestamps!

  many :postings

  def self.initialize_cache
    Dictionary.all.each do |dict|
      if Rails.cache.exist?(dict.term)
        logger.info("Skipping #{dict.term}, already in cache")
      else
        logger.info("adding #{dict.term} to cache")
        Rails.cache.write(dict.term, dict)
      end
    end
  end
end
