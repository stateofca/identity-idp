require File.expand_path('../../lib/s3_config_manager', __FILE__)
S3ConfigManager.new.download_configs

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
