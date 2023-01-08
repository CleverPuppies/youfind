# frozen_string_literal: true

# require_relative 'list_request'
require 'http'

module YouFind
  module Gateway
    # Infrastructure to call CodePraise API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def retrieve_video(video_id)
        @request.retrieve_video(video_id)
      end

      def retrieve_captions(video_id, search_input = '')
        @request.retrieve_captions(video_id, search_input)
      end

      def retrieve_highlighted_timestamps(video_id)
        @request.retrieve_highlighted_timestamps(video_id)
      end

      def add_video(video_id)
        @request.add_video(video_id)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def retrieve_video(video_id)
          call_api('get', ['video', video_id])
        end

        def retrieve_captions(video_id, search_input = '')
          params = search_input.empty? ? {} : { text: search_input }
          call_api('get', ['video', video_id, 'captions'], params)
        end

        def retrieve_highlighted_timestamps(video_id)
          call_api('get', ['video', video_id, 'highlights'])
        end

        def add_video(video_id)
          call_api('post', ['video', video_id])
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .then { |str| str ? "?#{str}" : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
              .then { |http_response| Response.new(http_response) }
        rescue StandardError => e
          puts e
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299)

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def failure?
          !success?
        end

        def ok?
          code == 200
        end

        def added?
          code == 201
        end

        def processing?
          code == 202
        end

        def message
          JSON.parse(payload)['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
