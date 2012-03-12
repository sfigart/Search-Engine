class SearchController < ApplicationController
  def index
    if params[:q]
      @q = params[:q]
      @query = Query.new
      @ranked_results = @query.process(@q)
      @postings = @query.postings.group_by {|posting| posting.docid} if @ranked_results.present?
      @message = (@ranked_results.present?) ? "Search results for #{@q}" : "No results found"
    end
  end
end
