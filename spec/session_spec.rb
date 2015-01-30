# encoding: UTF-8

require 'spec_helper'
require 'support/account'
require 'wakatime'
require 'webmock/rspec'

describe Wakatime::Session do
  before do

    @session = Wakatime::Session.new(
                                       api_key: 'Lame Key'
    )

    @client = Wakatime::Client.new(@session)

  end

  it 'raises a RequestError if a badly formed request detected by the server' do
    stub_request(:get, /.*\/summary.*/).to_return(status: 401, body: '{\n  \"errors\": [\n    \"UNAUTHORIZED\"\n  ]\n}', headers: {})
    expect { @client.summary }.to raise_error(Wakatime::AuthError)

    # make sure status and body is
    # set on error object.
    begin
      @client.summary
    rescue StandardError => e
      e.body.should eq '{\n  \"errors\": [\n    \"UNAUTHORIZED\"\n  ]\n}'
      e.status.should eq 401
    end
  end

  it 'raises a ServerError if the server raises a 500 error' do
    stub_request(:get, /.*\/summary.*/)
    .to_return(status: 503, body: '{"type": "error", "status": 503, "message": "We messed up!"}', headers: {})
    expect { @client.summary }.to raise_error(Wakatime::ServerError)

    # make sure status and body is
    # set on error object.
    begin
      @client.summary
    rescue StandardError => e
      e.body.should eq '{"type": "error", "status": 503, "message": "We messed up!"}' # TODO establish what happens when wakatime returns a 500 or something else.
      e.status.should eq 503
    end

  end
end
