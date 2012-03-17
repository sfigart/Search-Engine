class Dictionary
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  key :term, String
  key :doc_count, Integer
  key :tot_freq, Integer
  key :idf, Float

  timestamps!

  many :postings

  def self.initialize_cache
    Dictionary.all.each do |dict|
      Rails.cache.write(dict.term, [dict.term, dict.doc_count, dict.tot_freq, dict.idf ],
                        {:unless_exists => true})
    end
  end
end
