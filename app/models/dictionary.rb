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
      if Rails.cache.exist?(dict.term)
        logger.info("Skipping #{dict.term}, already in cache")
      else
        logger.info("adding #{dict.term} to cache")
        Rails.cache.write(dict.term, [dict.term, dict.doc_count, dict.tot_freq, dict.idf ])
      end
    end
  end

  def self.compute_cosine_similarity
    query = "hello"
    term = Dictionary.first(:term => query)
    docs = term.postings

    r = {}
    i = term.idf
    k = 1 # count of hello in query
    w = K * i

    puts "i: #{i}"
    puts "k: #{k}"
    puts "w: #{w}"

    docs.each do |doc|
      c = doc.freq
      if !r.has_key?(doc)
        r[doc] = 0
      end
      # Compute Dot Product
      r[doc] += w * i * c
    end
    puts "Dot Product"
    r.each do |doc, score|
      puts "#{doc.docid} #{score}"
    end

    # Computer length L of vector q
    # (square root of sum of squares)
    qv = [w]
    sum_of_squares = 0
    qv.each {|w| sum_of_squares += w ** 2}

    l = Math.sqrt(sum_of_squares)

    puts "Sum of Squares: #{sum_of_squares}"
    puts "Length of Q: #{l}"

    sums = {}
    docs.each do |doc|
      s = r[doc] * l
      y = doc.tfidf

      # Normalized score
      sums[doc] = s / (l * y)
    end

    puts "Cosine Similarity"
    sums.each do |doc, score|
      puts "#{doc.docid} #{score}"
    end
    nil
  end
end
