# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'caption_representer'

module YouFind
  module Representer
    # Represent a Video entity as json
    class Video < Roar::Decorator
      include Roar::JSON

      property :origin_id
      property :title
      property :url
      property :embedded_url
      property :time
      property :views
      collection :captions, extend: Representer::Caption,
                            class: OpenStruct

      private

      def origin_id
        represented.origin_id
      end
    end
  end
end
