# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'

describe 'Integration test of GetVideo service and API gateway' do
  it 'must return data of a specific video without it\'s captions' do
    # FIRST we ask for the indexation of a video
    YouFind::Gateway::Api.new(YouFind::App.config).add_video(VIDEO_ID)

    # THEN we request that same video
    res = YouFind::Service::GetVideo.new.call(VIDEO_ID)

    # THEN we should receive a video
    _(res.success?).must_equal true
    video = res.value!
    _(video.origin_id).must_equal VIDEO_ID
  end

  it 'must return error if video wasn\'t indexed before' do
    # WHEN we request another video than the one indexed previously
    res = YouFind::Service::GetVideo.new.call(VIDEO_ID_BIS)

    # THEN we should have received an error
    _(res.success?).must_equal false
  end
end