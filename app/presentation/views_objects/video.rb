# frozen_string_literal: true

module Views
  # View for a single video entity
  class Video
    def initialize(video)
      @video = video
    end

    def origin_id
      @video.origin_id
    end

    def entity
      @video
    end

    def title
      @video.title
    end

    def views
      @video.views
    end

    def time
      @video.time
    end

    def url
      @video.url
    end

    def embedded_url
      @video.embedded_url
    end

    def captions
      @video.captions
    end
  end
end
