require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require 'yaml'
require_relative 'lib/3gram_word_table.rb'

def load_all_philosophers
  table = load_philosopher("hume")
  # table.merge(load_philosopher("kant"))
  table.merge(load_philosopher("socrates"))
  table.merge(load_philosopher("descartes"))
  table.merge(load_philosopher("locke"))
  table
end

def load_philosopher(name)
  yaml_table = File.read("#{name}.txt")
  YAML::load(yaml_table)
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

table = load_all_philosophers
puts table.class

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