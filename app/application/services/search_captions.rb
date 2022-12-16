# frozen_string_literal: true

module YouFind
  module Service
    # Transaction to store video from Youtube API to database
    class SearchCaptions
      include Dry::Transaction

      step :request_captions
      step :reformat_json
      step :reify_captions

      private

      def request_captions(input)
        result = Gateway::Api.new(YouFind::App.config).retrieve_captions(input[:video_id], input[:search_input])
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot retrieve captions right now; please try again later')
      end

      def reformat_json(captions_json)
        json = JSON.parse(captions_json).map do |caption|
          JSON.parse(caption)
        end
        Success(JSON.generate({ 'captions' => json }))
      rescue StandardError => e
        puts e.inspect
        puts e.backtrace
        Failure('Cannot retrieve captions right now; please try again later')
      end

      def reify_captions(captions_json)
        Representer::Captions.new(OpenStruct.new)
                             .from_json(captions_json)
                             .then { |captions| Success(captions) }
      rescue StandardError => e
        puts e
        Failure('Error in the captions -- please try again')
      end
    end
  end
end
