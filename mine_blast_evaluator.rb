require 'byebug'
class MineBlastEvaluator

  # Create separate Module for FileParser

  def initialize(example_mines)
    # LOOP
    # byebug
    # if ENV['TEST']
    #   example_mines.each{|mine| mines << mine}
    # else
    File.foreach(example_mines) do |current_mine|
      current_mine = current_mine.gsub(/^\s+|\s+$/m, '')
      validate_mine_format(current_mine)
      mines << current_mine
    end
    # end
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

  # TODO just count instead of tracking mines?
  def total_blasts_by_mine
    @total_blasts_by_mine ||= {}
  end

  def load_blast_radius_mapping
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
      total_blasts_by_mine[mine] = blast_radius

      # LOOP
      blast_radius.each do |child_mine|
        next if (child_mine == mine)
        extended_blast_radius = get_mines_in_radius(child_mine)
        total_blasts_by_mine[mine] = total_blasts_by_mine[mine] | extended_blast_radius

        extended_blast_radius.each do |child_mine2|
          extended_blast_radius2 = get_mines_in_radius(child_mine2)
          total_blasts_by_mine[mine] = total_blasts_by_mine[mine] | extended_blast_radius
        end
      end

    end
  end

  def calculate_mines_in_radius(current_mine)
    mines_in_radius = []
    # LOOP
    mines.each do |mine|
      next if mine == current_mine
      mines_in_radius << mine if mine_within_radius(current_mine, mine)
    end
    mines_in_radius
  end

  def mine_within_radius(current_mine, mine)
    x1, y1, blast_radius = current_mine.split(' ')
    x2, y2 = mine.split(' ')[0..1]
    distance_btwn_mines = Math.sqrt((x1.to_i - x2.to_i) ** 2 + (y1.to_i - y2.to_i) ** 2).ceil
    return distance_btwn_mines <= blast_radius.to_i
  end

  def sort_mines_and_print_to_file
    # TODO if changed to count will simplify
    # TODO print to file earlier to save a loop?!?!?

    # file = File.open('sorted_mines.txt', 'w')

    # total_blasts_by_mine.sort_by{ |k, v| v.length}.reverse.each do |mine, blast_radius|
    #   file.puts "#{mine} (#{blast_radius.length})\n"
    # end

    # file.close

    # nvm -- don't return separate TEST data types
    # if ENV['TEST']
      # byebug
      # foobar = sorted_mines.map(&:first) do |mine, blast_radius|
      #   "#{mine} (#{blast_radius.length})"
      # end
      # return sorted_mines.map(&:first)
    # end

    File.open('sorted_mines.txt', 'w') do |file|
      sorted_mines.each do |mine, blast_radius|
        file.write "#{mine}\n"
      end
    end
  end

  def sorted_mines
    @total_blasts_by_mine.sort_by{ |k, v| v.length}.reverse
  end

  def validate_mine_format(current_mine)
    if current_mine !~ /^\s*(-?\d+\s+){2}\d+{1}\s*\z/
      raise Exception, "Invalid mine format!\nExpected 3 digits separated by whitespaces, e.g. 1 1 1\nReceived #{current_mine}"
    end
  end

end

# unless ENV['TEST']
mine_blast_evaluator = MineBlastEvaluator.new ARGV[0]
mine_blast_evaluator.execute
# end
