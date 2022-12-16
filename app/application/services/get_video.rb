# frozen_string_literal: true

require 'dry/transaction'

module YouFind
  module Service
    # Transaction to store video from Youtube API to database
    class GetVideo
      include Dry::Transaction

      step :request_video_without_captions
      step :reify_video

      private

      def request_video_without_captions(video_id)
        result = Gateway::Api.new(YouFind::App.config).retrieve_video(video_id)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot retrieve video right now; please try again later')
      end

      def reify_video(video_json)
        Representer::Video.new(OpenStruct.new)
                          .from_json(video_json)
                          .then { |video| Success(video) }
      rescue StandardError
        Failure('Error in the video -- please try again')
      end
    end
  end
end
