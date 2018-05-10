class Maze < ApplicationRecord

  has_many :blockers, dependent: :destroy

  MAX_SIZE_GRID = 1000
  GRID_MINIMUM_OFFSET = 2

  before_create :construct_maze

  def construct_maze
    self.width = rand(GRID_MINIMUM_OFFSET..MAX_SIZE_GRID)  # col = x = width
    self.height = rand(GRID_MINIMUM_OFFSET..MAX_SIZE_GRID) # row = y = height

    loop do # DFS check if possible to solve puzzle to ensure its possible, otherwise recreate
      randomize_blockers
      if is_maze_solvable?
        break
      end
    end
  end

  # Check starting and end points contained in solution
  # Check solution does not go diagonal or backwards
  # check solution point does not include a blocker
  def solve(solution_params)
    current_point = solution_params.shift
    end_point = solution_params.pop

    unless is_starting_point(current_point[:y], current_point[:x]) &&
      solution_params.length < 3 &&
      is_end_point(end_point[:y], end_point[:x])
      return false
    end

    solution_params.each do |point|
      binding.pry
      if is_valid_move(point, current_point)
        current_point = point
        next
      else
        return false
      end
    end
    true
  end

  def randomize_blockers
    num_of_blockers = rand(MAX_SIZE_GRID/3) + GRID_MINIMUM_OFFSET
    blockers = {}

    while num_of_blockers > 0 do
      num_of_blockers -= 1

      row = rand(self.height)
      col = rand(self.width)

      next if maze_blocker_invalid?(row, col)

      blockers["#{row}-#{col}"] = Blocker.new(x: col, y: row)
    end
    self.blockers = blockers.values
  end

  def check(y, x)
    self.blockers.where(x: x, y: y).present?
  end

  def is_maze_solvable?(current_x=0, current_y=0)
    if is_end_point(current_y, current_x)
      return true
    end

    if self.blockers.select { |invalid_block| invalid_block.x == current_x && invalid_block.y == current_y }.present? ||
      !within_bounds(current_y, current_x)
      return false
    end

    is_maze_solvable?(current_x + 1, current_y) || is_maze_solvable?(current_x , current_y + 1)
  end

  private

  def is_valid_move(target_point, reference_point)
    distance_x = target_point[:x] - reference_point[:x]
    distance_y = target_point[:y] - reference_point[:y]
    binding.pry
    if distance_x > 0 && distance_y > 0 # Diagonal move
      false
      # "Cannot make a diagonal move"
    elsif distance_x < 0 || distance_y < 0 # Moving backwards
      # "Cannot make a backwards move"
      false
    elsif self.blockers.where(x: target_point[:x], y: target_point[:y]).present? # Blocker
      # "You have reached a blocker"
      false
    else
      true
    end
  end

  def within_bounds(row, col)
    row < self.height && col < self.width
  end

  def is_starting_point(row, col)
    row == 0 && col == 0
  end

  def is_end_point(row, col)
    row == self.height - 1 && col == self.width - 1
  end

  #   Ensure blocker created for maze is not at the start or end points
  def maze_blocker_invalid?(row, col)
    is_starting_point(row, col) || is_end_point(row, col)
  end
end
