namespace :corpus do
  desc 'Indexer task'
  task :index => :environment do
    puts "Indexer task"
    tokens = []

    # Documents to index
    puts "\nStep 1 Parse documents"
    puts "===================="
    documents = Dir.glob("/Users/sfigart/code/csc575/project/cache/*")
    documents.each do |document|
      
      puts "Parsing #{document}"

      # Parse to get document text
      doc = Indexer::Parse.new(document)

      # Get terms
      terms = doc.text.downcase.split(' ')

      # Clean all non-word characters
      terms.each {|term| term.strip.gsub!(/\W/,'')}
      
      # Remove stop words
      stopwords = Indexer::Stopwords.new
      terms = terms - stopwords.list
      
      # Stem
      stemmed_terms = []
      terms.each {|term| stemmed_terms << term.stem}

      # extract as tokens
      docid = document.match(/.*\/(.*)\.html$/)[1]
      stemmed_terms.each {|term| tokens << Indexer::Token.new(term, docid) }
    end
      
    # 2 Sort Tokens by term, docid
    puts "\nStep 2 Sorted tokens"
    puts "===================="
    sorted_tokens = tokens.sort
    #puts sorted_tokens

    # Step 3 - Count document frequency by document
    merged = []
    puts "\nStep 3 Count document frequency by document"
    puts "==========================================="
    sorted_tokens.each do |item|
      next if item.term.empty?
      if merged.empty?
        merged << item
      elsif merged.last.term == item.term && merged.last.docid == item.docid
        merged.last.freq += 1
      else
        merged << item
      end
    end

    #puts merged

    # Step 4 - Create Dictionary
    puts "\nStep 4 Create Dictionary"
    puts "========================"
    dict = {}
    merged.each do |token|
      if dict.has_key?(token.term)
        dict[token.term].doc_count += 1
        dict[token.term].tot_freq += token.freq
      else
        dict[token.term] = Indexer::Dictionary.new(token.term, 1, token.freq)
      end
    end

    #pp dict

    # Step 5 - Create Postings
    puts "\nStep 5 Create Postings"
    puts "======================"
    postings = {}
    merged.each do |token|
      dict[token.term].postings << Indexer::Posting.new(token.docid, token.freq)
    end

    # Step 6 - Insert into in memory cache
    puts "\nStep 6 Insert into Redis"
    puts "======================"
    #$redis = Redis.new(:host => 'localhost', :port => 6379)
    dc = Dalli::Client.new('localhost:11211')
    dict.each do |term, dictionary|
      puts "adding #{term} in #{dictionary.doc_count} docs and #{dictionary.tot_freq} frequency"
      begin
        dc.set(term, dictionary)
      rescue ArgumentError => ex
        puts "failed to insert #{term} #{ex.message}"
      end
      #$redis.set(term, dictionary)
    end
  end
end
