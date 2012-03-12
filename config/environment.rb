# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SearchEngine::Application.initialize!

# Dont load rails cache if rails console or a rake task
if defined?(Rails::Console) || File.basename($0) == "rake"
  # do nothing
  Rails.logger.info("Skipping Dictionary initialization")
else
  # Load the dictionary into the Rails cache
  Rails.logger.info("Loading Dictionary items #{Dictionary.count} into Cache")
  Dictionary.initialize_cache
  Rails.logger.info("Loading Dictionary finished")
end
