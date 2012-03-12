class Query
  attr_accessor :postings

  # Algorithm from implementation.ppt slide 18
  def process(raw_query_terms)
    terms = analyze_terms(raw_query_terms) 

    q = [] # hold query term weights
    r = {} # stores retrieved documents and scores

    terms.each do |term|
      t = Rails.cache.read(term)
      next if t.nil? # This term is not in the dictionary

      term_idf = t[3]  # IDF of T (dictionary.idf)
      k = 1            # Count of T in Q
      w = k * term_idf # weight of query term (tf x idf)
      q << w           # save the weight for later

      # Compute posting tf x idf
      @postings = Posting.where(:term => term)
      @postings.each do |posting|
        d = posting.docid
        c = posting.freq # term frequency of T in D
        if r.has_key?(d)
          r[d] += w * term_idf * c  # (dot product)
          # Should be same as posting tfidf
        else
          r[d] = w * term_idf * c
        end
      end
    end

    # Compute the norm of the query terms
    l = compute_vector_length(q)

    scores = compute_cosine_similarity(r, l)

    # Sort in descending order by score
    result = scores.sort {|a1, a2| a2[1] <=> a1[1]}
  end

  private

  # Split the terms and send to 
  # InvertedIndex Cleaner to remove
  # stop words and stem the terms
  def analyze_terms(raw_query_terms)
    # Split into terms
    query_terms = raw_query_terms.split(' ')

    # Perform Lexical Analysis
    InvertedIndex::Cleaner.clean(query_terms)
  end

  # Compute the cosine similarity
  def compute_cosine_similarity(r, l)
    scores = {}
    r.each do |docid, score|
      y = Page.where(:docid => docid).fields(:vector_length).first.vector_length
      # Cosine similarity
      scores[docid] = score.to_f / (l * y).to_f
    end
    scores
  end

  # Square root of sum of squares
  def compute_vector_length(vector)
    # Sum of squares
    sum = 0
    vector.each {|v| sum += v ** 2}
    # Take square root
    Math.sqrt(sum)
  end
end
