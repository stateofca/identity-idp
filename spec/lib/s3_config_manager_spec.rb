require 'rails_helper'

RSpec.describe S3ConfigManager do
  let(:config_files) { %w[some_config.yml] }

  before { stub_const('S3ConfigManager::CONFIG_FILES', config_files) }

  let(:s3_client) { FakeS3.new }
  subject(:s3_config_manager) { S3ConfigManager.new(s3_client: s3_client) }

  describe '.download_configs' do
    subject(:download_configs) { s3_config_manager.download_configs }

    context 'when the env file does not exist' do
      it 'prints an error and does not download anything from s3' do
        expect($stderr).to receive(:puts).
          with("S3ConfigManager: no file exists at #{S3ConfigManager::CHEF_ENV_PATH}")
        expect(s3_client).to_not receive(:get_object)

        download_configs
      end
    end

    context 'when the env file exists' do
      let(:chef_env) { 'staging' }
      let(:config_body) { 'test config data' }

      before do
        allow(File).to receive(:exist?).with(S3ConfigManager::CHEF_ENV_PATH).and_return(true)
        allow(File).to receive(:read).with(S3ConfigManager::CHEF_ENV_PATH).and_return(chef_env)

        s3_client.put_object(
          bucket: S3ConfigManager::BUCKET,
          key: "v1/idp/#{chef_env}/some_config.yml",
          body: config_body
        )
      end

      after do
        FileUtils.rm(Rails.root.join('config', 'some_config.yml'))
      end

      it 'downloads files from s3 and writes them to the config directory' do
        download_configs

        expect(Rails.root.join('config', 'some_config.yml').read).to eq(config_body)
      end
    end
  end
end
