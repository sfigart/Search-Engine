# rake postings:generate[term_doc_freq.txt]
namespace :postings do
  desc 'Create or update posting records'
  task :generate, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "term_doc_freq.txt")

    puts "Generating postings from #{args.filename}"

    # Read each line from dictionary.txt
    file = File.open(args.filename, 'r')
    while (line = file.gets)
      klass, term, docid, freq, locations = line.chomp.split("\t")

      puts "working on #{term} #{docid}"

      if Posting.exists?(:term => term, :docid => docid)
        # Update
        posting = Posting.first(:term => term, :docid => docid)
      else
        # New
        posting = Posting.new(:term => term, :docid => docid)
      end

      posting.freq = freq
      posting.locations = locations

      # Compute tfidf (term freq * IDF)
      posting.dictionary = Dictionary.first(:term => posting.term)
      posting.tfidf = posting.freq * posting.dictionary.idf

      # Find corresponding page
      posting.page = Page.first(:docid => posting.docid)

      posting.save
    end
    file.close
  end
end
