require 'byebug'
require_relative '../lib/file_parser'

class MineBlastEvaluator
  include FileParser

  def initialize(mine_file)
    parse_file_and_load_mines(mine_file)
    execute
  end

  def execute
    load_blast_radius_mapping
    calculate_extended_blast_radius
    sort_mines_and_print_to_file
  end

  private

  def mines
    @mines ||= []
  end

  def blast_radius_by_mine
    @blast_radius_by_mine ||= {}
  end

  def total_blasts_by_mine
    @total_blasts_by_mine ||= {}
  end

  def load_blast_radius_mapping
    # LOOP
    mines.each do |current_mine|
      blast_radius_by_mine[current_mine] = get_mines_in_radius(current_mine)
      total_blasts_by_mine[current_mine] = []
    end
  end

  def get_mines_in_radius(current_mine)
    blast_radius_by_mine[current_mine] ||= calculate_mines_in_radius(current_mine)
  end

  def calculate_extended_blast_radius
    blast_radius_by_mine.each do |mine, blast_radius|
      add_child_blasts(mine, blast_radius)
    end
  end

  def add_child_blasts(mine, blast_radius)
    return if (blast_radius - total_blasts_by_mine[mine]).empty?
    # LOOP
    blast_radius.each do |child_mine|
      # NEED THIS?
      next if (child_mine == mine)
      extended_blast_radius = get_mines_in_radius(child_mine)
      total_blasts_by_mine[mine] = (blast_radius | extended_blast_radius)
      add_child_blasts(child_mine, extended_blast_radius)
    end
  end

  def calculate_mines_in_radius(current_mine)
    mines_in_radius = []
    # LOOP
    mines.each do |mine|
      next if mine == current_mine
      mines_in_radius << mine if mine_is_within_blast_radius(current_mine, mine)
    end
    mines_in_radius
  end

  def mine_is_within_blast_radius(current_mine, mine)
    x1, y1, blast_radius = current_mine.split(' ')
    x2, y2 = mine.split(' ')[0..1]
    distance_btwn_mines = Math.sqrt((x1.to_i - x2.to_i) ** 2 + (y1.to_i - y2.to_i) ** 2).ceil
    return distance_btwn_mines <= blast_radius.to_i
  end

  def sort_mines_and_print_to_file
    # LOOP
    file = File.open('sorted_mines.txt', 'w')
    total_blasts_by_mine.sort_by{ |mine, radius| radius.length }.reverse_each do |mine|
      file.write "#{mine.first}\n"
    end
    file.close
  end

end

MineBlastEvaluator.new(ARGV[0])
