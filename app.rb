require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require_relative 'lib/3gram_word_table.rb'

PHILOSOPHERS = ['hume', 'kant', 'socrates', 'descartes', 'locke']

#Methods
def create_philosopher_table
  phil_table = Hash.new
  PHILOSOPHERS.each do |phil|
    phil_table[phil] = WordTable.new("philosophical_works/#{phil}.txt")
  end
  phil_table["all"] = generate_word_table(PHILOSOPHERS, phil_table)
  phil_table
end

def generate_word_table(philosophers, table)
  word_table = WordTable.new
  philosophers.each do |phil|
    word_table.merge!(table[phil])
  end
  word_table
end

def parse_phil_request(phils, table)
  if !!phils && phils.length != 5
    generate_word_table(phils, table)
  else
    table["all"]
  end
end

def my_render(filename, quote=nil)
  results = File.read("public/layout.html.erb")
  results = ERB.new(results).result(binding) while results.include?("<%=")
  results
end

#Main Variables
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

#Routes
get '/' do
  my_render "public/home.html.erb"
end

post '/create' do
  phils = params["philosophers"]
  word_table = parse_phil_request(phils, table)
  key = SecureRandom.urlsafe_base64(16).to_s
  quote = word_table.generate_text
  REDIS.set(key, quote)
  redirect "/results?#{key}"
end

get '/results' do
  key = params.keys.first
  quote = REDIS.get(key)
  my_render "public/results.html.erb", quote
end