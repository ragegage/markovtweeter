require 'sinatra'
require 'json'
require 'byebug'

require_relative './markov_chain'

mh = {}
# hash of MarkovHashes

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/lookup/:username' do
  # mh[params[:username]] = "new tweet from #{params[:username]}"
  mh[params[:username]] = MarkovHash.from_twitter(params[:username])
  # create new MarkovHash
  {message: "got it"}.to_json
end

get '/lookup/:username/search' do
  {message: mh[params[:username]].string}.to_json
  # call #string on mh[params[:username]]
end
