class AdminController < ApplicationController
  def index
    term = "zynga"
    @terms = [ {term => Rails.cache.read(term)} ]
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
=begin
    @page = Page.first(:docid => docid)
    @doc = Nokogiri::HTML(@page.html)
    @body = @doc.css('body')
    @body.css('script').remove
    @body.css('style').remove
    @body.css('iframe').remove

    # Removing images because we are not interested in image tags for nohttp://digg.comw
    @images = @body.css('img').remove

    # Process anchor text separately because the .text function does not include
    # separators for link text
    @anchors = @body.css('a').remove
    @anchor_text = []
    @anchors.each {|a| @anchor_text << a.text}

    @text = @anchor_text.join(' ')

    # Replace all new lines and tabs with spaces
    @text << @body.text.gsub(/\n|\t/, ' ')

    # Replace apostrophe's with ''
    @text.gsub!(/\'/,'')

    # Replace all remaining non-word characters with spaces
    @text.gsub!(/\W/, ' ')
=end
  end
end

