#require 'mongo_mapper'

# rake crawler:not_visited[todo.txt]
namespace :crawler do
  task :not_visited, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "to_visit.txt")

    puts "Writing not visited pages to #{args.filename}"

    file = File.open(args.filename, 'w')
    pages = Page.not_visited
    pages.each do |page|
      file.puts page.url
    end
    file.close
  end
end
