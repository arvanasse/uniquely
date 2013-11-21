require 'rubygems'
require 'bundler'
Bundler.require :test

require './uniquely.rb'

describe Uniquely do
  before(:each){ @uniquely = Uniquely.new }

  describe '#sequences' do
    subject{ @uniquely.sequences }
    it{ should be_a_kind_of Hash }
  end

  describe "#unique_sequences" do
    subject{ @uniquely.unique_sequences }

    context "when no sequences have been added" do
      before(:each){ @uniquely.sequences.should be_empty }
      it{ should be_empty }
    end

    context "when only unique sequences have been added" do
      before :each  do 
        @uniquely.send :add_sequence, 'word', 'words'
        @uniquely.send :add_sequence, 'ords', 'words'
      end

      it{ @uniquely.unique_sequences.should eql @uniquely.sequences }
    end

    context "when duplicate sequences have been added" do
      before :each do
        @uniquely.send :add_sequence, 'andy', 'handy'
        @uniquely.send :add_sequence, 'word', 'words'
        @uniquely.send :add_sequence, 'ords', 'words'
        @uniquely.send :add_sequence, 'andy', 'dandy'
      end

      it "should return only the unique key/value pairs from #sequences" do
        @uniquely.unique_sequences.should eql({ :word => ['words'], :ords => ['words'] })
      end
    end
  end

  describe "#add_sequence" do
    let(:sequence){ 'andy' }
    let(:source){ 'handy' }

    context "if the sequences has not previously been encountered" do
      before :each do
        @uniquely.sequences.should_not include sequence
      end

      it "should add the sequence as a key in #sequences" do
        @uniquely.send :add_sequence, sequence, source
        @uniquely.sequences.should include :andy
      end

      it "should add the word into the array pointed to by the sequence" do
        @uniquely.send :add_sequence, sequence, source
        @uniquely.sequences[:andy].should == [source]
      end
    end

    context "if the sequence has already been stored" do
      before :each do
        @uniquely.send :add_sequence, sequence, 'dandy'
      end

      it "should add the sequence as a key in #sequences" do
        @uniquely.send :add_sequence, sequence, source
        @uniquely.sequences.should include :andy
      end

      it "should add the word into the array pointed to by the sequence" do
        @uniquely.send :add_sequence, sequence, source
        @uniquely.sequences[:andy].sort.should == [source, 'dandy'].sort
      end
    end
  end

  describe '#sequences_from' do
    subject{ @uniquely.send :sequences_from, word }

    context "when the word contains fewer than four characters" do
      let(:word){ 'two' }

      it "should return an empty array" do
        should be_empty
      end
    end

    context "when the word contains only four charactes" do
      let(:word){ 'word' }
      
      it "should return an array with one entry" do
        subject.size.should eql 1
      end

      it "should contain the word" do
        should include word
      end

      context "and the word includes a non-alpha character" do
        let(:word){ 'www1' }

        it "should return an empty array" do
          should be_empty
        end
      end
    end

    context "when the word contains more than four characters" do
      let(:word){ 'words' }

      it "should return an array with one entry for each four character sequence" do
        subject.size.should eql 2
      end

      it "should contain each substring of four characters" do
        %w[word ords].each{|sequence| should include sequence }
      end

      context "and the word includes a non-alpha character" do
        let(:word){ 'numb3r1' }

        it "should return an array with one entry of four alpha characters" do
          subject.size.should eql 1
        end

        it "should contain each substring of four alpha characters" do
          should include 'numb'
        end
      end
    end
  end

  describe "#parse_stream" do
    let(:input_stream){ StringIO.new( words.join("\n") ) }

    context "when there is only one line in the input stream" do
      let(:words){ %w[words] }

      it "should add all the sequences from the line in the input stream" do
        @uniquely.send :parse_stream, input_stream

        @uniquely.send(:sequences_from, words.first).each do |sequence| 
          @uniquely.sequences.should include sequence.to_sym
        end
      end

      it "should add the word as a value of all the sequences from the line in the input stream" do
        @uniquely.send :parse_stream, input_stream

        @uniquely.send(:sequences_from, words.first).each do |sequence| 
          @uniquely.sequences[sequence.to_sym].should include words.first
        end
      end
    end

    context "when there is more than one line in the input stream" do
      let(:words){ %w[words count] }

      it "should add all the sequences from each line in the input stream" do
        @uniquely.send :parse_stream, input_stream
        
        words.each do |source|
          @uniquely.send(:sequences_from, source).each do |sequence| 
            @uniquely.sequences.should include sequence.to_sym
          end
        end
      end

      it "should add the word as a value of all the sequences from each line in the input stream" do
        @uniquely.send :parse_stream, input_stream
        words.each do |source|
          @uniquely.send(:sequences_from, source).each do |sequence| 
            @uniquely.sequences[sequence.to_sym].should include source
          end
        end
      end

      context "when the lines contain duplicate sequences" do
        let(:words){ %w[andy is handy] }

        it "should add the word as a value of all the sequences from each line in the input stream" do
          @uniquely.send :parse_stream, input_stream
          words.each do |source|
            @uniquely.send(:sequences_from, source).each do |sequence| 
              @uniquely.sequences[sequence.to_sym].should include source
            end
          end
        end
      end
    end
  end

  describe "#parse_file" do
    subject{ @uniquely.send :parse_file }
    before(:each){ @uniquely = Uniquely.new(input_path: input_path ) }

    context "when the supplied input path does not exist" do
      let(:input_path){'nonexistent.txt'}
      it{ should eql false }
    end

    context "when the supplied input path exists" do
      let(:input_path){'sample.txt'}

      it{ should eql true }
      it "should open the file" do
        File.should_receive(:open).with(input_path)
        should eql true
      end

      it "should populate #sequences from" do
        @uniquely.sequences.should be_empty
        @uniquely.send :parse_file
        @uniquely.sequences.should_not be_empty
      end

      it "should include all the sequences for each word in the source file" do
        @uniquely.send :parse_file
        File.open(input_path) do |file|
          file.each_line do |source|
            @uniquely.send(:sequences_from, source.strip).each do |sequence|
              @uniquely.sequences.should include sequence.to_sym
              @uniquely.sequences[sequence.to_sym].should include source.strip
            end
          end
        end
      end
    end
  end
end
