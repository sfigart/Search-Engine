namespace :db do
  namespace :test do
    task :prepare do
      # Stub out for MongoDB
    end
    task :mongo => :environment do
      puts "mongo with environment"
    end
  end
end
