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
      res = settings.octokit.github_status.to_h
      res.to_json
    end

    get '/version' do
      {version: VERSION}.to_json
    end

    post '/:owner/:repo/:num/comments' do
      if request.content_type =~ %r|multipart/form-data|
        body = params['body'][:tempfile].read
      else
        body = params['body']
      end

      begin
        res = settings.octokit.add_comment("#{params[:owner]}/#{params[:repo]}", params[:num], body)
        {
          status: 'OK',
          url: res.html_url
        }.to_json
      rescue => e
        puts e, e.message, e.backtrace
        status_code 422
        {
          status: 'NG',
          error: e.class.to_s,
          error_message: e.message
        }.to_json
      end
    end
  end
end
