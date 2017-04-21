require 'rspec'

RSpec.describe 'MineBlastEvaluatorSpec' do


  context 'Sorting' do
    let(:test_mines) { ['2 -1 3', '-1 1 2', '2 2 2', '4 1 2', '1 1 1'] }
    let(:correct_sort_order) { ['2 -1 3', '2 2 2', '-1 1 2', '1 1 1', '4 1 2'] }

    before do
      load_test_data(test_mines)
      system('ruby lib/mine_blast_evaluator.rb seed_mines.txt')
    end

    it 'sorts mines in descending order by total number of explosions' do
      sorted_mines = File.open('sorted_mines.txt').map {|mine| mine.strip }
      expect(sorted_mines).to eq(correct_sort_order)
    end
  end

  context 'Validations' do
    let(:too_many_digits) { ['2 -1 3', '-1 1 2 5', '2 2 2'] }
    let(:too_few_digits) { ['2 -1 3', '-1 1', '2 2 2'] }
    let(:smushed_digits) { ['2 -1 3', '-1 11', '2 2 2'] }

    it 'validates too few digits' do
      load_test_data(too_few_digits)
    end

    it 'validates too few digits' do
      load_test_data(too_few_digits)
    end

    it 'validates whitespace' do
      load_test_data(smushed_digits)
    end

    after do
      expect(system('ruby lib/mine_blast_evaluator.rb seed_mines.txt')).to eq(false)
      expect($?.exitstatus).to eq(1)
    end
  end

  private

  def load_test_data(mines)
    file = File.open('seed_mines.txt', 'w')
    mines.each {|mine| file.write("#{mine}\n") }
    file.close
  end
end
