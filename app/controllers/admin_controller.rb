class AdminController < ApplicationController
  def index
    @terms = Dictionary.fields(:term).skip(1000).limit(2000)
  end

  def debug
    if params[:id]
      docid = params[:id]
    else
      docid = "67c72c2bf6168767e067943b4045efaf1b0cd533"
    end

    @page = Page.first(:docid => docid)
    parser = InvertedIndex::Parse.new(@page.html)
    @text = parser.parse
    @body = parser.body
    @tokens = parser.tokens
  end

  def show
    docid = params[:id]
    if docid
      @page = Page.first(:docid => docid)
    end
  end
end

