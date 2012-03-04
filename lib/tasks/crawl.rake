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

  task :update_visited, [:filename] => :environment do |t, args|
    args.with_defaults(:filename => "links_found.txt")

    puts "Updating visited from #{args.filename}"

    file = File.open(args.filename, 'r')
    while (line = file.gets)
      key, value = line.chomp.split("\t")
      puts "key #{key}, value: #{value}"
      unless Page.exists?(:url => key)
        Page.create(:url => key)
      end
    end
    file.close

  end
end
