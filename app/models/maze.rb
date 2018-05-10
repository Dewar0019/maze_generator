class Maze < ApplicationRecord
  MAX_SIZE_GRID = 40
  GRID_MINIMUM_OFFSET = 2
  BLOCKERS_DIFFICULTY = 3

  before_create :construct_maze

  def solve(solution_params)
    current_point = solution_params[0]
    end_point = solution_params[solution_params.length - 1]

    unless is_starting_point(current_point["y"], current_point["x"]) && is_end_point(end_point["y"], end_point["x"])
      return false
    end

    solution_params.each do |point|
      if is_valid_move(point, current_point)
        current_point = point
        next
      else
        return false
      end
    end

    true
  end

  def randomize_blockers(num_of_blockers)
    while num_of_blockers > 0 do
      num_of_blockers -= 1

      row = rand(self.height)
      col = rand(self.width)

      next if maze_blocker_invalid?(row, col)

      self.blockers["#{row}-#{col}"] = true
    end
  end

  def is_valid_space(y, x)
    !self.blockers["#{y}-#{x}"].present? && within_bounds(y, x)
  end

  def is_maze_solvable?(current_y=0, current_x=0, memoize={})
    if is_end_point(current_y, current_x)
      return memoize
    end

    if self.blockers["#{current_y}-#{current_x}"] || !within_bounds(current_y, current_x)
      return false
    end

    if memoize["#{current_y}-#{current_x}"]
      return false
    else
      memoize["#{current_y}-#{current_x}"] = true
    end

    is_maze_solvable?(current_y + 1, current_x, memoize) || is_maze_solvable?(current_y, current_x + 1, memoize)
  end

  private

  def construct_maze
    self.width = rand(GRID_MINIMUM_OFFSET..MAX_SIZE_GRID)  # col = x = width
    self.height = rand(GRID_MINIMUM_OFFSET..MAX_SIZE_GRID) # row = y = height

    maze_difficulty = BLOCKERS_DIFFICULTY

    # DFS check to ensure its possible to go through the maze, otherwise recreate
    loop do
      self.blockers = {} # reset blockers

      num_of_blockers = rand(MAX_SIZE_GRID/maze_difficulty) + GRID_MINIMUM_OFFSET
      randomize_blockers(num_of_blockers)
      if is_maze_solvable? # Will be a bottle neck if MAX_GRID_SIZE is too large
        break
      end
      maze_difficulty += BLOCKERS_DIFFICULTY # Decrease difficulty if unsolvable
    end
  end

  # Check point does not skip points over other points
  # Check solution does not go diagonal or backwards
  # Check solution point does not include a blocker
  def is_valid_move(target_point, reference_point)
    distance_x = target_point["x"] - reference_point["x"]
    distance_y = target_point["y"] - reference_point["y"]

    if distance_x > 0 && distance_y > 0 # Diagonal move
      false
    elsif distance_x > 1 || distance_y > 1 # Jumping a square
      false
    elsif distance_x < 0 || distance_y < 0 # Moving backwards
      false
    elsif !is_valid_space(target_point["y"], target_point["x"]) # Reached a blocker
      false
    else
      true
    end
  end

  def within_bounds(row, col)
    row < self.height && col < self.width && row >= 0 && col >= 0
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
