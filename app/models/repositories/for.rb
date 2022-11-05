require_relative 'videos'
require_relative 'captions'

module YouFind
    module Repository
        module For
            ENTITY_REPOSITORY = {
                Entity::Video => Videos,
                Entity::Caption => Captions
            }.freeze

            def self.klass(entity_klass)
                ENTITY_REPOSITORY[entity_klass]
            end

            def self.entity(entity_object)
                ENTITY_REPOSITORY[entity_object.class]
            end
        end
    end
end