module MinesFileParser

  def parse_file_and_load_mines(mine_file)
    File.foreach(mine_file) do |current_mine|
      current_mine = current_mine.gsub(/^\s+|\s+$/m, '')
      validate_mine_format(current_mine)
      mines << current_mine
    end
  end

  private

  def validate_mine_format(current_mine)
    if current_mine !~ /^\s*(-?\d+\s+){2}\d+{1}\s*\z/
      raise Exception, "Invalid mine format!\nExpected 3 digits separated by whitespaces, e.g. 1 1 1\nReceived #{current_mine}"
    end
  end
end