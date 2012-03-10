class Query
  # Algorithm from implementation.ppt slide 18
  def process(raw_query_terms)
    terms = analyze_terms(raw_query_terms) 

    q = [] # hold query term weights
    r = {} # stores retrieved documents and scores

    terms.each do |term|
      Rails.logger.debug "term : #{term}"
      t = Dictionary.first(:term => term)
      next if t.nil? # This term is not in the dictionary

      term_idf = t.idf # IDF of T
      k = 1            # Count of T in Q
      w = k * term_idf # weight of query term (tf x idf)
      q << w           # save the weight for later

      Rails.logger.debug "term #{term} #{w} tfidf"

      # Compute posting tf x idf
      t.postings.each do |posting|
        d = posting.docid
        c = posting.freq # term frequency of T in D
        Rails.logger.debug "c is #{c}"
        if r.has_key?(d)
          r[d] += w * term_idf * c  # (dot product)
          # Should be same as posting tfidf
          Rails.logger.debug "computed w * i * c = #{r[d]}"
          Rails.logger.debug "pre-computed #{w * posting.tfidf}"
        else
          Rails.logger.debug "adding #{d} to r"
          r[d] = w * term_idf * c
        end
      end
    end

    # Compute the norm of the query terms
    l = compute_vector_length(q)
    Rails.logger.debug "query term norm: #{l}"

    scores = compute_cosine_similarity(r, l)
    Rails.logger.debug "raw similarity scores"
    scores.each do |docid, score|
      Rails.logger.debug "#{docid}: #{score}"
    end

    # Sort in descending order by score
    result = scores.sort {|a1, a2| a2[1] <=> a1[1]}
    #result = scores.sort_by {|docid, score| score}.reverse

    Rails.logger.debug "sorted by similarity score descending"
    result.each do |doc_score|
      Rails.logger.debug "docid: #{doc_score[0]}\tscore: #{doc_score[1]}"
    end
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
    Rails.logger.debug "l is #{l}"
    scores = {}
    r.each do |docid, score|
      y = Page.where(:docid => docid).fields(:vector_length).first.vector_length
      Rails.logger.debug "y is #{y}"
      Rails.logger.debug "score is #{score}"
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
