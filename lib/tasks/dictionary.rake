# rake dictionary:generate[dictionary.txt]
namespace :dictionary do
  desc 'Create or update dictionary records'
  task :generate, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "dictionary.txt")

    puts "Generating dictionary from #{args.filename}"

    # Read each line from dictionary.txt
    file = File.open(args.filename, 'r')
    while (line = file.gets)
      term, doc_count, tot_freq = line.chomp.split("\t")
      if Dictionary.exists?(:term => term)
        dictionary = Dictionary.first(:term => term)
      else
        dictionary = Dictionary.new(:term => term)
      end

      dictionary.doc_count = doc_count.to_i
      dictionary.tot_freq = tot_freq.to_i
      dictionary.idf = 0 # Need to recompute in later task
      dictionary.save
    end
    file.close
  end

  desc 'Compute dictionary idf'
  task :compute_idf => :environment do

    puts "Computing IDF for all terms in dictionary"

    n = Dictionary.count
    terms = Dictionary.all
    terms.each do |dictionary|
      # Compute IDF using log2( (float)n / (float)doc_count )
      idf = Math.log2(n.to_f / dictionary.doc_count.to_f)
      dictionary.update_attribute(:idf, idf)
    end
  end

  desc 'Refresh cache'
  task :refresh_cache => :environment do
    puts 'refreshing cache'
    Dictionary.initialize_cache
  end
end
