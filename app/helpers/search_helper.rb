module SearchHelper
  def get_excerpt(docid, postings)
    excerpts = []
    begin
      count = 0
      postings[docid].each do |posting|
        posting.excerpts.each do |exc|
          excerpts << highlight(exc, posting.term)
          count += 1
          # Only include 3 excerpts
          break if count > 3
        end
      end
    rescue Exception => ex
      logger.error "~~~~~ get_excerpt (#{docid})"
      logger.error ex.message
    end

    excerpts.blank? ? "No excerpts for this term" : excerpts.join(" ... ")
  end
end
