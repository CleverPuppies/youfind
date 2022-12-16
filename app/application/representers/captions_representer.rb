# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'caption_representer'

module YouFind
  module Representer
    # Represent a Video entity as json
    class Captions < Roar::Decorator
      include Roar::JSON

      collection :captions, extend: Representer::Caption,
                            class: OpenStruct
    end
  end
end
