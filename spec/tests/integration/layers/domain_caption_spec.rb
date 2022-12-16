# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Test caption search' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
    DatabaseHelper.wipe_database

    @yt_video = YouFind::Youtube::VideoMapper
                .new(YT_API_KEY)
                .find(VIDEO_ID)

    YouFind::Repository::For.entity(@yt_video).create(@yt_video)
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should be able to do caption search' do
    root = @yt_video
    _(root.find_caption('google')[0].text)
      .must_equal "and so, it is so famous\nthat you can just google it,"
  end
end
