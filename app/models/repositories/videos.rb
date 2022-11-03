# require_relative 'captions'

# module YouFind
#     module Repository
#         # Repository for Video Entities
#         class Videos
#             def self.all
#                 Database::Video.all.map { |db_video| rebuild_entity(db_video) }
#             end

#             def self.find(entity)
#                 # origin_id uniquely identities a video
#                 find_origin_id(entity.origin_id)
#             end

#             def self.find_id(id)
#                 # SELECT * FROM `videos` WHERE id = id;
#                 db_record = Database::VideoOrm.first(id: id)
#                 rebuild_entity(db_record)
#             end

#             def self.find_origin_id(origin_id)
#                 # SELECT * FROM `videos` WHERE origin_id = origin_id;
#                 db_record = Database::VideoOrm.first(origin_id: origin_id)
#             end

#             def self.create(entity)
#                 raise 'Video already exists' if find(entity)
                
#                 db_video = VideoOrm.new(entity).call
#                 rebuild_entity(db_video)
#             end

#             def self.rebuild_entity(db_record)
#                 return nil unless db_record

#                 Entity:Video.new(
#                     db_record.to_hash.merge(
#                         captions: Captions.rebuild_many(db_record.captions)
#                     )
#                 )
#             end

#             # Helper class to persist video and its captions to database
#             class PersistVideo
#                 def initialize(entity)
#                     @entity = entity
#                 end

#                 def create_video
#                     Database::VideoOrm.create(@entity.to_attr_hash)
#                 end

#                 def call
#                 end
#             end
#         end
#     end
# end