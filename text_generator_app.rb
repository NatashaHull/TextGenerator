require 'sinatra'
require 'sinatra/reloader'
require_relative 'word_table.rb'

#Creates word generator table
def create_word_table
  table = WordTable.new("philosophical_works/kant.txt")
  table.add_file_to_table("philosophical_works/hume.txt")
  table.add_file_to_table("philosophical_works/descartes.txt")
  table.add_file_to_table("philosophical_works/locke.txt")
  table
end

table = create_word_table

get '/' do
  send_file 'home.html'
end

get '/results' do
  if !!params.keys.first
  else
    table.generate_text
  end
end