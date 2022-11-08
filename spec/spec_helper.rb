# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'yaml'
require 'vcr'
require 'webmock'

require_relative '../require_app'
require_app

VIDEO_ID = '8bZh5LMaSmE'
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
YT_API_KEY = YouFind::App.config.API_KEY
CORRECT = YAML.safe_load(File.read('spec/fixtures/yt_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'youtube_api'
