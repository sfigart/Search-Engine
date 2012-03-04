module Indexer
  class Posting
    attr_accessor :docid, :freq

    def initialize(docid, freq)
      @docid = docid
      @freq = freq
    end

    def to_s
      "<docid: #{docid}, freq: #{freq}>"
    end
  end
end
