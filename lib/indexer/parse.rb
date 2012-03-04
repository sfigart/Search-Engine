
module Indexer
  class Parse
    attr_accessor :filename, :doc, :text
    def initialize(filename)
      @filename = filename

      process
    end
    
    private

    def process
      f = File.open(@filename)
      @doc = Nokogiri::HTML(f)
      f.close

      # remove script tags
      @doc.search('script').remove
      @doc.search('style').remove

      body = @doc.at_css('body')

      # Content (strip leading/trailing spaces, newline and tabs)
      @text = body.content.strip.gsub(/\n|\t/,'') rescue 'Content_Not_Parsable'
    end
  end
end
