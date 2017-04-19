require 'byebug'
class MineBlastEvaluator

  def initialize(file)
    # LOOP
    File.foreach(file) do |current_mine|
      current_mine = current_mine.gsub(/^\s+|\s+$/m, '')
      mines << current_mine
    end
  end

  
  def execute
    generate_blast_radius_mapping

    # puts "mines => #{mines}"
    # puts "blast_radius_by_mine => #{blast_radius_by_mine}"
    
    # LOOP
    blast_radius_by_mine.each do |mine, blast_radius|
      total_blasts_by_mine[mine] = blast_radius

      # LOOP
      # TODO not sure if this is working
      blast_radius.each do |child_mine|
        add_downstream_blasts(child_mine, mine)
      end
    end
    
    # sorted_list = total_blasts_by_mine.sort_by{ |k, v| v.length}.reverse.map(&:first)
    puts total_blasts_by_mine
  end

  def mines
    @mines ||= []
  end

  private

  def blast_radius_by_mine
    @blast_radius_by_mine ||= {}
  end

  def total_blasts_by_mine
    @total_blasts_by_mine ||= {}
  end

  def generate_blast_radius_mapping
    mines.each do |current_mine| 
      blast_radius_by_mine[current_mine] = get_mines_in_radii(current_mine)
    end
  end

  def get_mines_in_radii(current_mine)
    blast_radius_by_mine[current_mine] ||= get_mines_in_radius(current_mine)
  end

  def get_mines_in_radius(current_mine)
    mines_in_radius = []
    # LOOPS
    mines.each do |mine|
      next if mine == current_mine
      mines_in_radius << mine if mine_within_radius(current_mine, mine)
    end
    mines_in_radius
  end

  def mine_within_radius(current_mine, mine)
    current_x, current_y, blast_radius = current_mine.split(' ')
    x, y = mine.split(' ')[0..1]
    distance_btwn_mines = Math.sqrt((current_x.to_i - x.to_i) ** 2 + (current_y.to_i - y.to_i) ** 2).floor
    return distance_btwn_mines <= blast_radius.to_i
  end

  def add_downstream_blasts(child_mine, mine)
    # LOOP
    get_mines_in_radii(child_mine).each do |child_blast_radius_mine|
      next if (total_blasts_by_mine[mine].include? child_blast_radius_mine) || (mine == child_blast_radius_mine)
      total_blasts_by_mine[mine] << child_blast_radius_mine
      add_downstream_blasts(child_blast_radius_mine, mine)
    end
  end

end

mine_blast_evaluator = MineBlastEvaluator.new ARGV[0]
mine_blast_evaluator.execute