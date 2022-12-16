# frozen_string_literal: true

require 'dry-validation'

module YouFind
  module Forms
    # Youtube video address validation
    class NewVideo < Dry::Validation::Contract
      URL_REGEX = %r{(https?)://(www.)?youtube\.com/.*\?v=.*$}

      params do
        required(:yt_video_url).filled(:string)
      end

      rule(:yt_video_url) do
        key.failure('is an invalid address for a Youtube video') unless URL_REGEX.match?(value)
      end
    end
  end
end
