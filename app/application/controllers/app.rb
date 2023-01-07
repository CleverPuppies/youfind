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
                    css: ['style.css'],
                    js: ['autocomplete.js', 'search_autocomplete.js']
    plugin :public, root: 'app/presentation/public'
    plugin :common_logger, $stderr
    plugin :halt
    plugin :caching

    route do |routing|
      routing.assets # load CSS
      routing.public # make public files available
      # routing.public_file "images/youfind_logo_600x461.png"

      response['Content-Type'] = 'text/html; charset=utf-8'

      session[:history] ||= []

      # GET /
      routing.root do
        url_history = session[:history].map do |url|
          {
            'label' => url,
            'value' => url
          }
        end
        view 'home', locals: { url_history: url_history }
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

            session[:history].insert(0, video_url[:yt_video_url]).uniq!

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

            highlights = []
            highlights_result = Service::GetHighlightedTimestamps.new.call({ video_id: video_id })

            if highlights_result.failure?
              flash[:error] = highlights_result.failure
              routing.redirect '/'
            end
            
            highlights_value = OpenStruct.new(highlights_result.value!) 

            if highlights_value.response.processing?
              flash.now[:notice] = 'Comments are being gathered for richer information'
            else
              highlights = highlights_value.payload # TODO
              video_data = video_result.value!
              video_data['captions'] = openstruct_to_h(captions_result.value!)[:captions]

              video = Views::Video.new(
                video_data
              )

              # Only use browser caching in production
              App.configure :production do
                response.expires 60, public: true
              end
            end

            processing = Views::CommentProcessing.new(
              App.config, highlights_value.response
            )
            
            view 'video', locals: { video: video, highlights: highlights, processing: processing }
          end
        end
      end
    end
  end
end
