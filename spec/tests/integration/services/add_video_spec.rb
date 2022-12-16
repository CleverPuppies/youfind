# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'

describe 'AddVideo Service Integration Test' do
  it 'HAPPY: should be able to find and save remote video to database' do
    # WHEN we request to add a project
    url_request = YouFind::Forms::NewVideo.new.call(yt_video_url: VIDEO_URL)

    video_saved = YouFind::Service::AddVideo.new.call(url_request)

    # THEN we should receive the generate video
    _(video_saved.success?).must_equal true

    rebuilt = video_saved.value!

    _(rebuilt.origin_id).must_equal VIDEO_ID
    _(rebuilt.url).must_equal VIDEO_URL
  end
end