class SearchController < ApplicationController
  def index
    if params[:q]
      @q = params[:q]
      @results = search_for(@q)
    else
      @results = nil
    end
  end

  def search_for(query)
    # Need to stop list
    # Need to stemmify
    search_terms = query.split(' ')
    hits = {}
    search_terms.each do |term|
      stem_term = term.strip.stem.downcase
      hits[term] = Rails.cache.read(stem_term) if Rails.cache.exist?(stem_term)
    end

    # Union results

    [hits]
  end
end
