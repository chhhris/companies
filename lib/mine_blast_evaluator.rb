require 'byebug'
class MineBlastEvaluator

  # Create separate Module for FileParser

  def initialize(mine_file)
    # LOOP
    File.foreach(mine_file) do |current_mine|
      current_mine = current_mine.gsub(/^\s+|\s+$/m, '')
      validate_mine_format(current_mine)
      mines << current_mine
    end
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
      # list_of_blasts = blast_radius
      add_child_blasts(mine, blast_radius)

      # LOOP

      # DRY this up
      # TODO this isn't RECURSIVE so if big numbers of mines are thrown at it, might it not cycle all the way through?!


    end
  end

  def add_child_blasts(mine, blast_radius)
    return if (blast_radius - total_blasts_by_mine[mine]).empty?
    blast_radius.each do |child_mine|
      # NEED THIS?
      next if (child_mine == mine)

      extended_blast_radius = get_mines_in_radius(child_mine)
      total_blasts_by_mine[mine] = (blast_radius | extended_blast_radius)

      add_child_blasts(child_mine, extended_blast_radius)

      # extended_blast_radius.each do |child_mine2|
      #   childs_extended_blast_radius = get_mines_in_radius(child_mine2)
      #   total_blasts_by_mine[mine] = (blast_radius | extended_blast_radius | childs_extended_blast_radius)

      #   # next if (childs_extended_blast_radius - total_blasts_by_mine[mine]).empty?
      #   # next if (child_mine2 == mine) || (total_blasts_by_mine[mine].include? child_mine2)
      #   add_child_blasts(child_mine2, childs_extended_blast_radius)
      # end
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
    # TODO print to file earlier to save a loop?!?!?

    File.open('sorted_mines.txt', 'w') do |file|
      sorted_mines.each do |mine, blast_radius|
        file.write "#{mine}\n"
      end
    end
  end

  def sorted_mines
    total_blasts_by_mine.sort_by{ |k, v| v.length }.reverse
  end

  def validate_mine_format(current_mine)
    if current_mine !~ /^\s*(-?\d+\s+){2}\d+{1}\s*\z/
      raise Exception, "Invalid mine format!\nExpected 3 digits separated by whitespaces, e.g. 1 1 1\nReceived #{current_mine}"
    end
  end

end

mine_blast_evaluator = MineBlastEvaluator.new ARGV[0]
mine_blast_evaluator.execute
