require 'byebug'
class MineBlastEvaluator

  def initialize(file)
    # LOOP
    File.foreach(file) do |current_mine|
      # current_mine = current_mine.gsub(/^\s+|\s+$/m, '')
      validate_mine_format current_mine
      mines << current_mine
    end
  end

  
  def execute
    load_blast_radius_mapping
    calculate_extended_blast_radius
    sort_mines_and_print_to_file
    # puts "mines => #{mines}"
    # puts "blast_radius_by_mine => #{blast_radius_by_mine}"
    
    # LOOP
    # byebug

    # blast_radius_by_mine.each {|mine, blast_radius| puts "mine #{mine} blast_radius #{blast_radius}"}
    
    
    # byebug
    puts "blast_radius_by_mine #{blast_radius_by_mine.values.map(&:length)}"
    # blast_list = blast_radius_by_mine.sort_by{ |k, v| v.length}.reverse.map(&:first)

    puts "total_blasts_by_mine #{total_blasts_by_mine.values.map(&:length)}" #{total_blasts_by_mine}"
    # total_blasts_by_mine.values.map(&:length)
    
    # puts sorted_list
    
  end

  def mines
    @mines ||= []
  end

  private

  def sort_mines_and_print_to_file
    sorted_list = total_blasts_by_mine.sort_by{ |k, v| v.length}.reverse.map { |mine, blast_radius| "#{mine} (#{blast_radius.length})" }
    puts "sorted_list #{sorted_list}"
  end
  
  def validate_mine_format(current_mine)
    if current_mine !~ /^\s*(-?\d+\s+){2}\d+{1}\s*\z/
      raise Exception, "Invalid mine format!\nExpected 3 digits separated by whitespaces, e.g. 1 1 1\nReceived #{current_mine}"
    end
  end

  def calculate_extended_blast_radius
    blast_radius_by_mine.each do |mine, blast_radius|
      # total_blasts_by_mine[mine] = [] 
      total_blasts_by_mine[mine] = blast_radius
      # byebug
    #   # LOOP
      blast_radius.each do |child_mine|
        # TODO not sure if this is working
        # byebug

        next if (child_mine == mine)
        extended_blast_radius = get_mines_in_radius(child_mine)
        total_blasts_by_mine[mine] = total_blasts_by_mine[mine] | extended_blast_radius

        extended_blast_radius.each do |child_mine2|
          extended_blast_radius2 = get_mines_in_radius(child_mine2)
          total_blasts_by_mine[mine] = total_blasts_by_mine[mine] | extended_blast_radius
        end
        # total_blasts_by_mine[mine] = total_blasts_by_mine[mine].flatten
        # add_downstream_blasts(child_mine, mine)
      end

    end
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
    if blast_radius_by_mine[current_mine].nil?
      mines_in_radius = []
      mines.map do |mine|
        next if mine == current_mine
        if mine_within_radius(current_mine, mine)
          mines_in_radius << mine
        end
      end
      mines_in_radius
    else
      blast_radius_by_mine[current_mine]
    end
  end

  # def get_mines_in_radius(current_mine)
  #   blast_radius_by_mine[current_mine] ||= get_mines_in_radius(current_mine)
  # end

  # def get_mines_in_radius(current_mine)
  #   mines_in_radius = []
  #   # LOOPS
  #   mines.each do |mine|
  #     next if mine == current_mine
  #     mines_in_radius << mine if mine_within_radius(current_mine, mine)
  #   end
  #   mines_in_radius
  # end

  def mine_within_radius(current_mine, mine)
    current_x, current_y, blast_radius = current_mine.split(' ')
    x, y = mine.split(' ')[0..1]
    distance_btwn_mines = Math.sqrt((current_x.to_i - x.to_i) ** 2 + (current_y.to_i - y.to_i) ** 2).ceil
    return distance_btwn_mines <= blast_radius.to_i
  end

  def add_downstream_blasts(child_mine, mine)
    # LOOP
    # byebug
    blast_radius_by_mine[child_mine].each do |child_blast_radius_mine|
      # byebug
      next if (total_blasts_by_mine[mine].include? child_blast_radius_mine) || (mine == child_blast_radius_mine)
      total_blasts_by_mine[mine] << child_blast_radius_mine
      add_downstream_blasts(child_blast_radius_mine, mine)
    end
  end

end

mine_blast_evaluator = MineBlastEvaluator.new ARGV[0]
mine_blast_evaluator.execute