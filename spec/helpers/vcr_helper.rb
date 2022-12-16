# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'youtube_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
    end
  end

  def self.configure_vcr_for_youtube(recording: :new_episodes)
    VCR.configure do |c|
      c.filter_sensitive_data('<RAPIDAPI_KEY>') { YT_API_KEY }
      c.filter_sensitive_data('<RAPIDAPI_KEY_ESC>') { CGI.escape(YT_API_KEY) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: recording,
      match_requests_on: %i[method uri headers],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
