require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require_relative 'lib/3gram_word_table.rb'

PHILOSOPHERS = ['hume', 'kant', 'socrates', 'descartes', 'locke']

def create_philosopher_table
  phil_table = Hash.new
  PHILOSOPHERS.each do |phil|
    phil_table[phil] = WordTable.new("philosophical_works/#{phil}.txt")
  end
  phil_table
end

def generate_word_table(philosophers, table)
  word_table = WordTable.new
  philosophers.each do |phil|
    word_table.merge!(table[phil])
  end
  word_table
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

table = create_philosopher_table

get '/' do
  send_file 'public/home.html'
end

post '/create' do
  if !!params["philosophers"]
    word_table = generate_word_table(params["philosophers"], table)
  else
    word_table = generate_word_table(PHILOSOPHERS, table)
  end
  key = SecureRandom.urlsafe_base64(16).to_s
  quote = word_table.generate_text
  REDIS.set(key, quote)
  redirect "/results?#{key}"
end

get '/results' do
  key = params.keys.first
  quote = REDIS.get(key)
  results = File.read("public/results.html.erb")
  ERB.new(results).result(binding)
end