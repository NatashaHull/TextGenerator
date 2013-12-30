require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require_relative 'lib/3gram_word_table.rb'

def create_word_table
  table = WordTable.new("philosophical_works/hume.txt")
  # table.add_file_to_table("philosophical_works/kant.txt")
  table.add_file_to_table("philosophical_works/socrates.txt")
  table.add_file_to_table("philosophical_works/descartes.txt")
  table.add_file_to_table("philosophical_works/locke.txt")
  table
end


if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
elsif Sinatra::Base.development?
  REDIS = Redis.new
else
  uri = URI.parse(ENV["REDIS_CACHE"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => ENV["REDIS_PASS"])
end

table = create_word_table

get '/' do
  send_file 'public/home.html'
end

get '/results' do
  key = params.keys.first
  if !!key
    quote = REDIS.get(key)
  else
    key = SecureRandom.urlsafe_base64(16).to_s
    quote = table.generate_text
    REDIS.set(key, quote)
    redirect "/results?#{key}"
  end
  results = File.read("public/results.html.erb")
  ERB.new(results).result(binding)
end