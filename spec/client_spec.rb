#encoding: UTF-8

require 'spec_helper'
require 'support/account'
require 'wakatime'
require 'webmock/rspec'

describe Wakatime::Client do
  before do
    @session = Wakatime::Session.new
  end

  describe '#summary' do
    it "should return json" do
      stub_request(:get, "#{Wakatime::API_URL}/summary")
      .with(:query => hash_including(:start, :end))
      .to_return(:body => File.read('./spec/fixtures/summary.json'), :status => 200)

      client = Wakatime::Client.new(@session)
      client.summary.grand_total.total_seconds.should eq 49740

    end
  end
end
