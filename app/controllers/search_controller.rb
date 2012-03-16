class SearchController < ApplicationController
  def index
    # is a query present?
    if params[:q]
      @q = params[:q]
      @query = Query.new

      # Parse the query
      @ranked_results = @query.process(@q)

      # Group results by posting
      @postings = @query.postings.group_by {|posting| posting.docid} if @ranked_results.present?

      # Set the search result message
      @message = (@ranked_results.present?) ? "Search results for #{@q}" : "No results found for #{@q}"
    end
  end
end
