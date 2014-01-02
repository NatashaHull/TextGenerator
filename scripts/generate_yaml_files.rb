require 'yaml'
require_relative '../lib/3gram_word_table.rb'

def create_word_tables
  create_yaml_file(WordTable.new("philosophical_works/hume.txt"), "hume")
  create_yaml_file(WordTable.new("philosophical_works/kant.txt"), "kant")
  create_yaml_file(WordTable.new("philosophical_works/socrates.txt"), "socrates")
  create_yaml_file(WordTable.new("philosophical_works/descartes.txt"), "descartes")
  create_yaml_file(WordTable.new("philosophical_works/locke.txt"), "locke")
end

def create_yaml_file(table, name)
  File.open("#{name}.yaml", "w") do |file|
    file.puts table.to_yaml
  end
end

create_word_tables