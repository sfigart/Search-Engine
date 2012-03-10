# rake page:compute_vector_length
namespace :page do
  desc 'Create or update page vector length (norm)'
  task :compute_vector_length => :environment do

    puts "Computing vector length"

    # Get unique documents from postings
    docids = Posting.collection.distinct("docid",nil)

    puts "#{docids.size} docids to process"

    # Compute the vector length for each document
    docids.each do |docid|
      sum = 0
      page = Page.first(:docid => docid)

      # Sum the squares of each posting's tfidf weight
      page.postings.fields(:tfidf).each {|posting| sum += posting.tfidf ** 2}

      # Take the square root of the sum of square
      # as the document length (norm)
      page.update_attribute(:vector_length, Math.sqrt(sum))

      puts "#{page.vector_length}\t#{page.indexed}\t#{page.postings.count}\t#{docid}"
    end
  end
end
