module Indexer
  class Dictionary
    attr_accessor :term, :doc_count, :tot_freq, :postings

    def initialize(term, doc_count, tot_freq, postings=[])
      @term = term
      @doc_count = doc_count
      @tot_freq = tot_freq
      @postings = postings
    end

    def to_s
      "Term: #{term}, N docs: #{doc_count}, Tot Freq: #{tot_freq}, Postings: #{postings}"
    end
  end
end
