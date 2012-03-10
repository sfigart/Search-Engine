class HtmlStub
  attr_accessor :text, :html
end

class PageController < ApplicationController
  def show
    @page = Page.first(:docid => params[:id]) if params[:id]
    parser = InvertedIndex::Parse.new(@page.html)
    text = parser.parse
    @html = HtmlStub.new
    @html.text = text
    @html.html = parser.doc.html
  end
end

