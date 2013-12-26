require 'json'

class WordTable
  def initialize(filename=nil)
    @table = Hash.new
    add_file_to_table(filename) if !!filename
  end

  def add_file_to_table(filename)
    doc = parse_file(filename)
    
    #Add first word
    @table["."] ||= []
    @table["."] << doc[0]

    #Add second word
    @table[". #{doc[0]}"] ||= []
    @table[". #{doc[0]}"] << doc[1]

    #Add the rest
    (1...doc.length).each do |word_i|
      if doc[word_i] == "."
        @table["."] << doc[word_i+1]
      else
        key = "#{doc[word_i-1]} #{doc[word_i]}"
        @table[key] ||= []
        @table[key] << doc[word_i+1]
      end
    end
  end

  def generate_text
    text = @table["."].sample
    text += text_loop(".", text)
    text.gsub(/\s+([.,!?])/, '\1')
  end

  private

    def parse_file(filename)
      File.readlines(filename).join.gsub(/([.,!?])/, ' \1').split(/\s+/)
    end

    def text_loop(prev_word, curr_word)
      next_word = find_next_word(prev_word, curr_word)
      text = " #{next_word}"
      if [".", "?", "!"].include?(next_word) && should_stop?
        text
      else
        text + text_loop(curr_word, next_word)
      end
    end

    def find_next_word(prev_word, curr_word)
      if curr_word == "."
        next_word = @table["."].sample
      else
        next_word = @table["#{prev_word} #{curr_word}"].sample
      end
    end

    def should_stop?
      rand < 0.6
    end
end