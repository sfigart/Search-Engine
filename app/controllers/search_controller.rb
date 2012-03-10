class SearchController < ApplicationController
  def index
    if params[:q]
      query = Query.new
      @ranked_results = query.process(params[:q])
      @message = (@ranked_results.present?) ? "Search results for #{params[:q]}" : "No results found"
    end
  end

  def search_for(query)

    # See ~/code/csc575/assignment3/problem1.rb for 
    # dot product and cosine similarity computation
    
    search_terms = query.split(' ')

    # Lex the terms
    terms = InvertedIndex::Cleaner.clean(search_terms)

    results = {}
    terms.each do |term|
      # TODO: WHY HAVING TROUBLE GETTING Dictionary out of Memcached?
      if Dictionary.exist?(:term => term)
        results[term] = Dictionary.first(:term => term)
      end
      #if Rails.cache.exist?(term)
      #  results[term] = Rails.cache.read(term)
      #  logger.debug("Put #{term} in results")
      #end
    end
    results
  end
end
