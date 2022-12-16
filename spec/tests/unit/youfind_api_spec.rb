# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'

describe 'Unit test of YouFind API gateway' do
  it 'must report alive status' do
    alive = YouFind::Gateway::Api.new(YouFind::App.config).alive?
    _(alive).must_equal true
  end

  it 'must be able to add a video' do
    res = YouFind::Gateway::Api.new(YouFind::App.config)
      .add_video(VIDEO_ID)
    
    _(res.success?).must_equal true
    data = res.parse
    _(data['origin_id']).must_equal VIDEO_ID
  end

  it 'must return a video' do
    # GIVEN a video is in the database
    YouFind::Gateway::Api.new(YouFind::App.config)
      .add_video(VIDEO_ID)

    # WHEN we request the video
    res = YouFind::Gateway::Api.new(YouFind::App.config)
      .retrieve_video(VIDEO_ID)

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    data = res.parse
    _(data['origin_id']).must_equal VIDEO_ID
    _(data['url']).must_equal VIDEO_URL
  end

  it 'must return the captions from a specific video' do
    # GIVEN a video is in the database
    YouFind::Gateway::Api.new(YouFind::App.config)
      .add_video(VIDEO_ID)

    # WHEN we request the captions
    res = YouFind::Gateway::Api.new(YouFind::App.config)
      .retrieve_captions(VIDEO_ID)

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    data = res.parse
    _(data.count).must_equal 956

    # WHEN we request the captions with a search input
    res = YouFind::Gateway::Api.new(YouFind::App.config)
      .retrieve_captions(VIDEO_ID, 'green')

    # THEN we should see a single project in the list
    _(res.success?).must_equal true
    data = res.parse
    _(data.count).must_equal 65
  end
end