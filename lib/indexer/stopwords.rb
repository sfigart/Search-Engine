module Indexer
  class Stopwords
    attr_reader :list

    def initialize(stopfilename='/Users/sfigart/code/rails_projects/web/lib/indexer/stopwords.txt')
      @list = []
      file = File.open(stopfilename,'r')
      while (word = file.gets)
        @list << word.chomp
      end
      file.close
    end
  end
end
