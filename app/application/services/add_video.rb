# frozen_string_literal: true

require 'dry/transaction'

module YouFind
  module Service
    # Transaction to store video from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :validate_url
      step :request_video
      step :reify_video

      private

      def validate_url(input)
        if input.success?
          video_id = input[:yt_video_url].split('v=')[-1]
          Success(video_id: video_id)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def request_video(input)
        result = Gateway::Api.new(YouFind::App.config).add_video(input[:video_id])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot add video right now; please try again later')
      end

      def reify_video(video_json)
        Representer::Video.new(OpenStruct.new)
                          .from_json(video_json)
                          .then { |video| Success(video) }
      rescue StandardError => e
        puts e
        Failure('Error in the video -- please try again')
      end
    end
  end
end
