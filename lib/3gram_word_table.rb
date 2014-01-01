class WordTable
  def initialize(filename=nil)
    @table = Hash.new
    add_file_to_table(filename) if !!filename
  end

  def add_file_to_table(filename)
    doc = parse_file(filename)
    add_first_word(doc)
    add_second_word(doc)
    add_remaining_words(doc)
  end

  def generate_text
    text = @table["."].sample
    text += text_loop(".", text)
    text.gsub(/\s+([.,!?])/, '\1')
  end

  def merge(other_table)
    @table.merge!(other_table.table) do |key, old_val, new_val|
      old_val + new_val
    end
  end

  protected

    attr_reader :table

  private

    def parse_file(filename)
      File.readlines(filename).join.gsub(/([.,!?])\s+/, ' \1 ').split(/\s+/)
    end

    def add_first_word(doc)
      @table["."] ||= []
      @table["."] << doc[0]
    end

    def add_second_word(doc)
      @table[". #{doc[0]}"] ||= []
      @table[". #{doc[0]}"] << doc[1]
    end

    def add_remaining_words(doc)
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
        @table["."].sample
      else
        @table["#{prev_word} #{curr_word}"].sample
      end
    end

    def should_stop?
      rand < 0.6
    end
end

#Test
table = WordTable.new("philosophical_works/hume.txt")
other_table = WordTable.new("philosophical_works/socrates.txt")

table.merge(other_table)