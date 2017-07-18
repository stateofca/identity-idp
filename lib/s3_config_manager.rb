require 'aws-sdk-core'

class S3ConfigManager
  CHEF_ENV_PATH = '/etc/login.gov/info/env'.freeze
  BUCKET = 'login-dot-gov-app-secrets-prod'.freeze

  CONFIG_FILES = %w[
    database.yml
    application.yml
  ].freeze

  def initialize(s3_client: nil)
    @s3_client = s3_client
  end

  def download_configs
    unless File.exist?(CHEF_ENV_PATH)
      $stderr.puts "#{self.class}: no file exists at #{CHEF_ENV_PATH}"
      return
    end

    CONFIG_FILES.each do |config_file|
      download_config(config_file)
    end
  end

  private

  def chef_env
    @chef_env ||= File.read(CHEF_ENV_PATH).chomp
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new
  end

  def download_config(config_file)
    s3_client.get_object(
      bucket: BUCKET,
      key: "v1/idp/#{chef_env}/#{config_file}",
      response_target: Rails.root.join('config', config_file).to_s
    )
  end
end
