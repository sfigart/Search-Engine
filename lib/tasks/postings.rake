# rake postings:generate[term_doc_freq.txt]
namespace :postings do
  desc 'Create or update posting records'
  task :generate, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "term_doc_freq.txt")

    puts "Generating postings from #{args.filename}"

    # Read each line from input (term_doc_freq.txt)
    file = File.open(args.filename, 'r')
    while (line = file.gets)
      klass, term, docid, freq, locations = line.chomp.split("\t")

      puts "working on #{term} #{docid}"

      begin
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
      rescue Exception => e
        puts "Exception #{e.message} for"
        puts "#{line}"
        if !posting.new?
          posting.delete
        end
      end
    end
    file.close
  end

  desc 'Create or update posting records'
  task :create_excerpts => :environment do
    # Process postings in alpha order to limit loading
    # all records into memory at one time
    ('a'..'z').each do |alpha|
      # All Postings starts with alpha ignorecase
      postings = Posting.where(:term => Regexp.new("^#{alpha}", Regexp::IGNORECASE ))
      puts "Creating excerpts for #{alpha} (#{postings.size})"
      postings.each_with_index do |posting, index|
        puts "#{index} - create excerpts for #{posting.term}"
        excerpts = posting.page.get_excerpts(posting.term)

        if excerpts.blank?
          puts "Excerpt is blank for #{posting.term} #{posting.docid}" if excerpts.blank?
        else
          posting.update_attribute(:excerpts, excerpts) 
        end
      end
    end
  end
end
