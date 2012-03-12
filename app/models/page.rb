# REMEMBER TO UPDATE ./mapreduce/crawler.rb definition if you
# change this substantially
class Page
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  # Included for excerpt function
  include ActionView::Helpers::TextHelper

  key :docid, String
  key :name, String
  key :url, String
  key :visited, Boolean
  key :last_visited, Date
  key :last_visited_status_code
  key :html, String
  key :indexed, Boolean

  key :vector_length, Float

  timestamps!

  many :postings

  # Returns all models where visited is not true
  def self.not_visited
    Page.all(:visited => [false, nil])
  end

  def self.not_indexed
    Page.where(:indexed => [false, nil], :visited => true).fields(:docid)
  end

  def get_excerpts(phrase, *args)
    terms = phrase.split(' ')

    doc = Hpricot(self.html)
    doc.search('head').remove
    doc.search('script').remove
    doc.search('style').remove
    doc.search('iframe').remove
    doc.search('embed').remove

    snippets = []
    nodes =  (doc/"body//*/text()")
    # Delete all empty nodes
    nodes = nodes.delete_if {|node| node.to_s.strip.blank?}

    # Find the excerpt
    nodes.each do |node|
      text = node.to_plain_text.chomp.strip
      terms.each do |term|
        regex = Regexp.new(term, Regexp::IGNORECASE )
        if regex =~ text
          snippets << excerpt(text, term, *args)
          #snippets << highlight(snippet, terms, :highlighter => '<em>\1</em>')
          #break # exit on first match of any term
        else
          logger.warn "NO MATCH on #{term}!!!"
          logger.warn text
          logger.warn "~~~~~~~~~~~~"
        end
      end
    end
    results = snippets.uniq
    logger.info "Found #{results.size} excerpts"
    results
  end
end
