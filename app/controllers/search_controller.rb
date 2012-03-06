class SearchController < ApplicationController
  def index
    if params[:q]
      @q = params[:q]
      @results = search_for(@q)
      @postings = []
      @results.values.each do |dict|
        dict.postings.each do |posting|
          @postings << posting
        end
      end
    else
      @results = nil
    end
  end

  def search_for(query)
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
