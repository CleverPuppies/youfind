# frozen_string_literal: true

module YouFind
  # module for helper functions used in the routing
  module RouteHelpers
    def openstruct_to_h(object)
      object.to_h.transform_values do |value|
        case value
        when OpenStruct
          openstruct_to_h(value)
        when Array
          value.map { |v| v.is_a?(String) ? v : openstruct_to_h(v) }
        else
          value
        end
      end
    end
  end
end
