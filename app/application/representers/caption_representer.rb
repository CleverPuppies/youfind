# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module YouFind
  module Representer
    # Represent caption as JSON
    class Caption < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia

      property :start
      property :duration
      property :text
    end
  end
end
