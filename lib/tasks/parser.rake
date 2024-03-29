# rake parser:not_indexed[to_parse.txt]
namespace :parser do
  desc 'Generate list of pages to parse'
  task :not_indexed, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "to_parse.txt")

    puts "Writing pages to parse to #{args.filename}"

    file = File.open(args.filename, 'w')
    pages = Page.not_indexed
    pages.each {|page| file.puts page.docid}
    file.close
  end

  desc 'Mark pages indexed'
  task :mark_indexed, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "to_parse.txt")

    puts "Marking pages indexed from #{args.filename}"

    file = File.open(args.filename, 'r')
    while (line = file.gets)
      page = Page.first(:docid => line.chomp.strip)
      page.update_attribute(:indexed, true)
    end
    file.close
  end
end
