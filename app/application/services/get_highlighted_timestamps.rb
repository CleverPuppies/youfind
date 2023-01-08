# frozen_string_literal: true

require 'dry/transaction'

module YouFind
  module Service
    # Transaction to store video from Youtube API to database
    class GetHighlightedTimestamps
      include Dry::Transaction

      step :request_timestamps
      #step :reify_timestamps

      private

      def request_timestamps(input)
        input[:response] = Gateway::Api.new(YouFind::App.config)
                                       .retrieve_highlighted_timestamps(input[:video_id])
        input[:response].success? ? Success(input) : Failure(input[:response].message)
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot retrieve video right now; please try again later')
      end

      def reify_timestamps(input)
        unless input[:response].processing?
          Representer::ProjectFolderContributions.new(OpenStruct.new)
                                                 .from_json(input[:response].payload)
                                                 .then { input[:appraised] = _1 }
        end

        Success(input)
        # rescue StandardError
        #   Failure('Error while collecting timestamps -- please try again')
      end
    end
  end
end
