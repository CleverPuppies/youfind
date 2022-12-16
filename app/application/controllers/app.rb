# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

require_relative 'helpers'

module YouFind
  # Web App
  class App < Roda
    include RouteHelpers

    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css'
    plugin :common_logger, $stderr
    plugin :halt
    plugin :caching

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        view 'home'
      end

      routing.on 'video' do
        routing.is do
          # POST /video
          routing.post do
            video_url = Forms::NewVideo.new.call(routing.params)
            video_saved = Service::AddVideo.new.call(video_url)

            if video_saved.failure?
              flash[:error] = video_saved.failure
              routing.redirect '/'
            end

            video = video_saved.value!
            routing.redirect "video/#{video.origin_id}"
          end
        end

        routing.on String do |video_id|
          # GET /video/{video_id}?text={captions_search_text}
          routing.get do
            search_input = routing.params['text'] || ''

            video_result = Service::GetVideo.new.call(video_id)
            if video_result.failure?
              flash[:error] = video_result.failure
              routing.redirect '/'
            end

            captions_result = Service::SearchCaptions.new.call({ video_id: video_id, search_input: search_input })
            if captions_result.failure?
              flash[:error] = captions_result.failure
              routing.redirect '/'
            end

            video_data = video_result.value!
            video_data['captions'] = openstruct_to_h(captions_result.value!)[:captions]

            video = Views::Video.new(
              video_data
            )

            App.configure :production do
              response.expires 60, public: true
            end
            view 'video', locals: { video: video }
          end
        end
      end
    end
  end
end
