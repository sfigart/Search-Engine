# rake parser:not_indexed[to_parse.txt]
namespace :parser do
  desc 'Generate list of pages to parse'
  task :not_indexed, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "to_parse.txt")

    puts "Writing #{args.limit} pages to parse to #{args.filename}"

    pages = Page.not_indexed
    file = File.open(args.filename, 'w')
    pages.each {|page| file.puts page.docid}
    file.close
  end
end
