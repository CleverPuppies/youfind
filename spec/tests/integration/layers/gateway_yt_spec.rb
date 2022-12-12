# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'

describe 'Tests environment' do
  it 'must be in testing environment' do
    _(ENV.fetch('RACK_ENV', nil)).must_equal 'test'
  end
end

describe 'Tests Youtube API library' do
  VcrHelper.setup_vcr
  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Video information' do
    it 'HAPPY: gateway should work' do
      gateway = YouFind::Youtube::API.new(YT_API_KEY)
      video = gateway.video_data(VIDEO_ID)
      _(video).wont_be_nil
      _(video['title']).must_equal CORRECT['title']
    end

    it 'HAPPY: video should be found' do
      video_mapper = YouFind::Youtube::VideoMapper
                     .new(YT_API_KEY)
      _(video_mapper).wont_be_nil
    end

    it 'HAPPY: should provide correct video info' do
      video = YouFind::Youtube::VideoMapper
              .new(YT_API_KEY)
              .find(VIDEO_ID)
      _(video.title).must_equal CORRECT['title']
      _(video.url).must_equal CORRECT['url']
      _(video.origin_id).must_equal CORRECT['id']
      _(video.time).must_equal CORRECT['duration']
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
          YouFind::Youtube::VideoMapper
          .new('BAD_TOKEN')
          .find('cleverpuppies')
        end).must_raise YouFind::Youtube::API::Response::Forbidden
    end
  end

  describe 'Captions' do
    before do
      @captions = YouFind::Youtube::CaptionMapper
                  .new(YT_API_KEY)
                  .load_captions(VIDEO_ID)
    end

    it 'HAPPY: should be able to retrieve captions' do
      _(@captions).wont_be_nil
    end

    it 'HAPPY: should have start, duration, text' do
      first_slice = @captions.first
      _(first_slice[:start].to_s).must_equal CORRECT['captions'][0]['start']
      _(first_slice[:duration].to_s).must_equal CORRECT['captions'][0]['dur']
      _(first_slice[:text]).must_equal CORRECT['captions'][0]['text']
    end
  end
end
