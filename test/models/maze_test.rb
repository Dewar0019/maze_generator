require 'test_helper'

class MazeTest < ActiveSupport::TestCase
  # [ O O ]
  # [ X X ]
  # [ O O ]
  # [ O O ]
  test "maze method:is_maze_solvable? equates to true after removing blocker" do
    maze = Maze.find(ActiveRecord::FixtureSet.identify('unsolvable'))
    assert_equal false, maze.is_maze_solvable?

    maze.blockers.delete "1-0"

    assert maze.is_maze_solvable?
  end

  # [ O O ]
  # [ X X ]
  # [ O O ]
  # [ O O ]
  test "maze method:check determines where blockers are" do
    maze = Maze.find(ActiveRecord::FixtureSet.identify('unsolvable'))

    assert_equal false, maze.is_valid_space(1,0)
    assert_equal false, maze.is_valid_space(1,1)

    assert maze.is_valid_space(2,1)
  end

  context "maze method:solve" do
    # [ O O ]
    # [ O X ]
    # [ O O ]
    # [ O O ]
    setup do
      @maze = Maze.find(ActiveRecord::FixtureSet.identify('solvable'))
    end

    should "return false if solution does not contain starting point" do
      solution = [
        # { "y" => 0, "x" => 0 }, # Missing Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      assert_equal false, @maze.solve(solution)
    end

    should "return false if solution does not contain end point" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 3, "x" => 0 },
        # { "y" => 3, "x" => 1 }  # Missing End point
      ]

      assert_equal false, @maze.solve(solution)
    end

    should "return false if solution includes a diagonal move" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 3, "x" => 1 }  # Illegal diagonal move to end
      ]

      assert_equal false, @maze.solve(solution)
    end

    should "return false if solution reaches a blocker" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 1, "x" => 1 }, # Reaches a blocker
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      assert_equal false, @maze.solve(solution)
    end

    should "return false if solution goes backwards" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      assert_equal false, @maze.solve(solution)
    end

    should "return false if solution moves more than one space at a time" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 3, "x" => 0 }, # Jumped data point
        { "y" => 3, "x" => 1 }  # End point
      ]

      assert_equal  false, @maze.solve(solution)
    end

    # [ 0 O ]
    # [ 0 X ]
    # [ 0 O ]
    # [ 0 0 ]
    should "return true if solution meets requirements" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      assert @maze.solve(solution)
    end
  end
end
