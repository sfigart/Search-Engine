module SearchHelper
  def get_excerpt(docid, postings)
    excerpt = postings[docid].first.excerpts.first rescue nil
    return highlight excerpt, postings[docid].first.term rescue 'No excerpt is available'
  end
end
