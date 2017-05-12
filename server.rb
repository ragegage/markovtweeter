require 'sinatra'
require 'json'

require_relative './markov_chain'

mh = {}
# hash of MarkovHashes

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/lookup/:username' do
  unless mh[params[:username]]
    mh[params[:username]] = MarkovHash.from_twitter(params[:username])
  end
  {message: "got it"}.to_json
end

get '/lookup/:username/search' do
  {message: mh[params[:username]].string}.to_json
end
