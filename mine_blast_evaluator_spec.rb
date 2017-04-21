require 'byebug'
# require_relative 'mine_blast_evaluator'

# tests
# sorts mines correctly given different inputs
# validates input
# too many digits
# strips extra spaces
# any size digit pos or negative
#

# OR OR OR should i test that it updates the file?
# good thing with that is functionality matches real world usage

# overkill?
# test private methods like initial blast radius and extended blast radius???



class MineBlastEvaluatorSpec
  class << self

    def run_tests
      sorts_mines_correctly
    end

    def sorts_mines_correctly
      test_data = ["2 -1 3", "-1 1 2", "2 2 2", "4 1 2", "1 1 1"]
      load_test_data(test_data)

      system('ruby mine_blast_evaluator.rb seed_mines.txt')
      # mine_blast_evaluator = MineBlastEvaluator.new(test_data)
      # mine_blast_evaluator.execute

      # sorted_mines = FileParser
      # sorted_mines = []
      # .each {|line| puts line}
      # byebug
      # sorted_mines = File.open('sorted_mines.txt')
      sorted_mines = File.open('sorted_mines.txt').map {|mine| mine.strip }
      #   sorted_mines <<
      #   sorted_mines.each do |mine, blast_radius|
      #     file.write "#{mine} (#{blast_radius.length})\n"
      #   end
      # end
      correctly_sorted = ["2 -1 3", "2 2 2", "-1 1 2", "1 1 1", "4 1 2"]
      test_result = sorted_mines == correctly_sorted ? 'Passing' : 'Failing'
      puts "#{test_result}: #{__callee__}"
    end

    private

    def load_test_data(mines)
      file = File.open('seed_mines.txt', 'w')
      mines.each {|mine| file.write("#{mine}\n") }
      file.close
    end
  end

end

MineBlastEvaluatorSpec.run_tests
# ENV['FOOBAR'] ||= nil
# puts ENV['FOOBAR']
# puts $FOOBAR
