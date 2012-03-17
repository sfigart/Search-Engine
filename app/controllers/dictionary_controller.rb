class DictionaryController < ApplicationController
  def index
    @alpha = params[:alpha] || 'a'
    regex = Regexp.new("^#{@alpha}", Regexp::IGNORECASE)
    @terms = Dictionary.paginate(:term => regex, :page => params[:page], :per_page => 100)
  end
end
