module YouFind
    module Service
      # Transaction to store video from Youtube API to database
      class SearchCaptions
        include Dry::Transaction
  
        step :request_captions
        step :reify_captions
  
        private
  
        def request_captions(video_id, search_input)
          result = Gateway::Api.new(YouFind::App.config).retrieve_captions(video_id, search_input)
          result.success? ? Success(result.payload) : Failure(result.message)
        rescue StandardError => e
          puts e.inspect
          puts e.backtrace
          Failure('Cannot retrieve captions right now; please try again later')
        end
  
        def reify_caption(captions_json)
          captions_json.map do |caption_hash|
            Representer::Caption.new(OpenStruct.new)
              .from_json(caption_hash)
              .then { |caption| Success(caption) }
          end
          rescue StandardError
            Failure('Error in the captions -- please try again')
        end
      end
    end
  end