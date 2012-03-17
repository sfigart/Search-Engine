# rake postings:generate[a]
namespace :postings2 do
  desc 'Create or update posting records'
  task :create_excerpts, [:alpha] => :environment do |t, args|

    # All Postings starts with alpha ignorecase
    postings = Posting.where(:term => Regexp.new("^#{args.alpha}", Regexp::IGNORECASE ))
    puts "Creating excerpts for #{args.alpha} (#{postings.size})"
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
