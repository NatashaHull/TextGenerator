require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require_relative 'word_table.rb'

def create_word_table
  table = WordTable.new("philosophical_works/kant.txt")
  table.add_file_to_table("philosophical_works/hume.txt")
  table.add_file_to_table("philosophical_works/descartes.txt")
  table.add_file_to_table("philosophical_works/locke.txt")
  table
end

table = create_word_table
redis = Redis.new

get '/' do
  send_file 'home.html'
end

get '/results' do
  key = params.keys.first 
  if !!key
    quote = redis.get(key)
  else
    key = SecureRandom.urlsafe_base64(16).to_s
    quote = table.generate_text
    redis.set(key, quote)
    redirect "/results?#{key}"
  end
  quote
end