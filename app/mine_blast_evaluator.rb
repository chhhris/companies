require 'byebug'
require_relative '../lib/file_parser'

class MineBlastEvaluator
  include FileParser

  def initialize(mine_file)
    parse_file_and_load_mines(mine_file)
    execute
  end

  def execute
    generate_blast_radius_mapping
    calculate_total_blast_radius
    # byebug
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

  def generate_blast_radius_mapping
    # LOOP
    mines.each do |current_mine|
      blast_radius_by_mine[current_mine] = mines_in_radius(current_mine)
      total_blasts_by_mine[current_mine] = []
    end
  end

  def mines_in_radius(current_mine)
    blast_radius_by_mine[current_mine] ||= calculate_mines_in_radius(current_mine)
  end

  def calculate_total_blast_radius
    blast_radius_by_mine.each do |mine, blast_radius|
      total_blasts_by_mine[mine] = blast_radius
      add_child_blasts_to_mine(mine, blast_radius)
    end
  end

  def add_child_blasts_to_mine(mine, blast_radius)
    blast_radius.each do |child_mine|
      child_mine_blast_radius = mines_in_radius(child_mine)
      diff = child_mine_blast_radius - total_blasts_by_mine[mine]
      next if diff.empty?
      total_blasts_by_mine[mine] += diff
      add_child_blasts_to_mine(mine, diff)

      # return if blast_radius.empty? || (blast_radius - total_blasts_by_mine[mine]).empty?
    # return if

    # LOOP
      # byebug
      # mines_in_extended_blast_radius = mines_in_radius(child_mine) - blast_radius - [mine]

      # total_blasts_by_mine[mine] = total_blasts_by_mine[mine] | mines_in_extended_blast_radius
      # add_child_blasts_to_mine(mine, mines_in_extended_blast_radius)


      # total_blasts_by_mine[mine] = total_blasts_by_mine[mine] | child_blast_radius
      # unless (child_blast_radius - blast_radius).empty?
      #   add_child_blasts_to_mine(mine, child_blast_radius)
      # end


      # extended_blast_radius = mines_in_radius(child_mine)


      # total_blasts_by_mine[mine] = (total_blasts_by_mine[mine] | blast_radius | extended_blast_radius)

      # add_child_blasts_to_mine(mine, extended_blast_radius)
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
    distance_btwn_mines = Math.sqrt((x1.to_i - x2.to_i) ** 2 + (y1.to_i - y2.to_i) ** 2)
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
