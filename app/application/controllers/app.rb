# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module YouFind
  # Web App
  class App < Roda
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
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
            routing.redirect "video/#{video.video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /video/{video_id}?text={captions_search_text}
          routing.get do
            search_input = routing.params['text']
            video_data = Service::GetVideo.new.call(video_id, search_input)
            video_data['captions'] = Service::SearchCaptions.new.call()

            video = Views::Video.new(
              video_data,
              routing.params['text'] || ''
            )

            view 'video', locals: { video: video }
          end
        end
      end
    end
  end
end
