require "sinatra/base"
require "octokit"
require "json"
require "octochan/version"

module Octochan
  class App < Sinatra::Base
    configure do
      set :octokit, -> {
        options = {:access_token => settings.access_token}
        options[:api_endpoint] = settings.api_root if settings.respond_to?(:api_root)

        Octokit::Client.new options
      }
    end


    before do
      content_type "application/json"
    end

    get '/' do
      redirect '/version'
    end

    get '/status' do
      res = settings.octokit.issues "udzura/octochan"
      res.map(&:to_h).to_json
    end

    get '/version' do
      {version: VERSION}.to_json
    end
  end
end
