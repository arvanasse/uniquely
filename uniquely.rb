class Uniquely
  attr_reader :sequences
  attr_accessor :input_path

  def initialize( input_path: './dictionary.txt', word_path: 'words.txt', sequence_path: 'sequences.txt' )
    @input_path, @word_path, @sequence_path = input_path, word_path, sequence_path
    clear_sequences
  end

  def process_file
    if parse_file
      sequence_file = File.open(@sequence_path, 'w')
      word_file = File.open(@word_path, 'w')

      self.unique_sequences.each do |sequence, source|
        sequence_file.puts sequence
        word_file.puts source.first
      end

      # sequence_file.close
      # word_file.close
    end
  end

  def unique_sequences
    @sequences.select{|sequence, sources| sources.size == 1 }
  end

  private
    def parse_file
      if !File.exist?(@input_path)
        puts "\nFile #{@input_path} does not exist\n"
        return false
      end
    
      File.open(@input_path) do |stream|
        parse_stream stream
      end

      true
    end

    def parse_stream(stream)
      stream.each_line do |source|
        source.strip!
        sequences_from(source).each{|sequence| add_sequence sequence, source }
      end
    end

    def add_sequence(sequence, source)
      key = sequence.respond_to?(:to_sym) ? sequence.to_sym : sequence
      @sequences[key] ||= []
      @sequences.merge! key => @sequences[key].push( source )
    end

    def sequences_from(word)
      @four_alphas ||= /[a-z|A-Z]{4}/
      Range.new(0, word.size-4).map{|pos| word[pos, 4] }.select{|sequence| sequence =~ @four_alphas }
    end

    def clear_sequences
      #
      # Normally I would use Hash.new(Array.new)
      # In Ruby 2.0.0-p247, it seems that this approach does not return a new array for each
      # uninitialized key, but _the same_ array created when the hash is initialized.
      #
      @sequences ||= {}
      @sequences.clear
    end
end
