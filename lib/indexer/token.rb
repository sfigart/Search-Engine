module Indexer
  class Token
    attr_accessor :term, :docid, :freq
    def initialize(term, docid, freq = 1)
      @term = term
      @docid = docid
      @freq = freq
    end
    def to_s
      "#{term}, #{docid}, #{freq}"
    end

    # Compare by term, docid, freq
    def <=>(that)
      result = term <=> that.term
      if result == 1 || result == -1
        result
      else
        result = docid <=> that.docid
        if result == 1 || result == -1
          result
        else
          freq <=> that.freq
        end
      end
    end
  end
end
