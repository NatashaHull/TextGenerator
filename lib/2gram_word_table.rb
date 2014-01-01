class WordTable
  def initialize(filename=nil)
    @table = Hash.new
    add_file_to_table(filename) if !!filename
  end

  def add_file_to_table(filename)
    doc = parse_file(filename)
    @table["."] ||= []
    @table["."] << doc[0]
    doc.each_index do |word_i|
      break if word_i == (doc.length-1)
      @table[doc[word_i]] ||= []
      @table[doc[word_i]] << doc[word_i+1]
    end
  end

  def generate_text
    text = @table["."].sample
    text += text_loop(text)
    puts text.gsub(/\s+([.,!?])/, '\1')
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
      File.readlines(filename).join.gsub(/([.,!?])/, ' \1').split(/\s+/)
    end

    def text_loop(curr_word)
      next_word = @table[curr_word].sample
      text = " #{next_word}"
      if [".", "?", "!"].include?(next_word) && should_stop?
        text
      else
        text + text_loop(next_word)
      end
    end

    def should_stop?
      rand < 0.6
    end
end