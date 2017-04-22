require 'byebug'
require_relative '../lib/file_parser'

class MineBlastEvaluator
  include FileParser

  def initialize(mine_file)
    parse_file_and_load_mines(mine_file)
    execute
  end

  def execute
    calculate_total_blast_radii
    sort_mines_and_print_to_file
  end

  private

  def mines
    @mines ||= []
  end

  def blast_radius_by_mine
    @blast_radius_by_mine ||= {}
  end

  def total_blasts_tracker
    @total_blasts_tracker ||= {}
  end

  def fetch_mines_in_radius(current_mine)
    blast_radius_by_mine[current_mine] ||= calculate_radius(current_mine)
  end

  def calculate_radius(current_mine)
    mines.map do |mine|
      next if mine == current_mine
      mine if mine_is_within_blast_radius(current_mine, mine)
    end.compact
  end

  def calculate_total_blast_radii
    mines.each do |current_mine|
      byebug if current_mine.nil?
      blast_radius = fetch_mines_in_radius(current_mine)
      total_blasts_tracker[current_mine] = blast_radius
      add_blasts_from_radius(current_mine, blast_radius)
    end
  end

  def add_blasts_from_radius(current_mine, blast_radius)
    blast_radius.each do |child_mine|
      byebug if child_mine.nil?
      blast_radius_of_child_mine = fetch_mines_in_radius(child_mine)
      descendant_mines = blast_radius_of_child_mine - total_blasts_tracker[current_mine]
      next if descendant_mines.empty?
      total_blasts_tracker[current_mine] += descendant_mines
      add_blasts_from_radius(current_mine, descendant_mines)
    end
  end

  def mine_is_within_blast_radius(current_mine, mine)
    x1, y1, blast_radius = current_mine.split(' ')
    x2, y2 = mine.split(' ')[0..1]
    distance_btwn_mines = Math.sqrt((x1.to_i - x2.to_i) ** 2 + (y1.to_i - y2.to_i) ** 2)
    return distance_btwn_mines <= blast_radius.to_i
  end

  def sort_mines_and_print_to_file
    file = File.open('sorted_mines.txt', 'w')
    total_blasts_tracker.sort_by{ |mine, radius| radius.length }.reverse_each do |mine|
      file.write "#{mine.first}\n"
    end
    file.close
  end

end

MineBlastEvaluator.new(ARGV[0])
