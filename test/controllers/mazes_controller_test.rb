require 'test_helper'

class MazesControllerTest < ActionDispatch::IntegrationTest
  context "POST /maze" do
    should "returns a json object on details of the maze created" do
      post mazes_path
      assert_response :success
      parsed_body = JSON.parse(response.body)

      assert parsed_body.key?("id")
      assert parsed_body.key?("height")
      assert parsed_body.key?("width")

      # minimum size of maze
      assert parsed_body["height"] > 2
      assert parsed_body["width"] > 2
    end
  end

  # [ O O ]
  # [ X X ]
  # [ O O ]
  # [ O O ]
  context "GET /maze/{id}/check?x={x position}&y={y position}" do
    setup do
      @maze = Maze.find(ActiveRecord::FixtureSet.identify('unsolvable'))
    end

    should "return a 200 response with body 'invalid' when blocker is reached" do
      get check_maze_url(@maze.id), params: { maze: { id: @maze.id, x: 1, y: 1 } }
      assert_response :success
      assert_equal "invalid", response.body
    end

    should "return a 200 response with body 'valid' when open space is reached" do
      get check_maze_url(@maze.id), params: { maze: { id: @maze.id, x: 1, y: 0 } }
      assert_response :success
      assert_equal "valid", response.body
    end

    should "return a 400 response with body 'missing coordinates' when open space is reached" do
      get check_maze_url(@maze.id), params: { maze: { id: @maze.id, x: 1 } }
      assert_equal 400, response.status
      assert_equal "missing coordinates", response.body
    end
  end


  context "POST /maze/{id}/solve" do
    setup do
      @maze = Maze.find(ActiveRecord::FixtureSet.identify('solvable'))
    end

    should "return a 400 response with body 'missing solution' when solution is missing" do
      post solve_maze_url(@maze.id)
      assert_equal 400, response.status
      assert_equal "missing solutions", response.body
    end

    # [ O O ]
    # [ O X ]
    # [ O O ]
    # [ O O ]
    should "return a 200 response with body 'correct' when solution is valid" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 2, "x" => 0 },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      post solve_maze_url(@maze.id), params: { solution: solution.to_json }
      assert_equal 200, response.status
      assert_equal "correct", response.body
    end

    should "return a 200 response with body 'incorrect' when solution is invalid" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 1, "x" => 1 },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      post solve_maze_url(@maze.id), params: { solution: solution.to_json }
      assert_equal 200, response.status
      assert_equal "incorrect", response.body
    end

    should "return a 400 response with body 'invalid solutions format' when solution format is incorrect" do
      solution = [
        { "y" => 0, "x" => 0 }, # Starting point
        { "y" => 1, "INCORRECT" => 0 },
        { "y" => 1, "x" => 1 },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      post solve_maze_url(@maze.id), params: { solution: solution.to_json }
      assert_equal 400, response.status
      assert_equal "invalid solutions format", response.body
    end


    should "return a 200 response with body 'incorrect' when solution values are not integers" do
      solution = [
        { "y" => "ELDEM", "x" => 0 }, # Starting point
        { "y" => 1, "x" => 0 },
        { "y" => 1, "x" => "ALEDLEADM" },
        { "y" => 3, "x" => 0 },
        { "y" => 3, "x" => 1 }  # End point
      ]

      post solve_maze_url(@maze.id), params: { solution: solution.to_json }
      assert_equal 200, response.status
      assert_equal "incorrect", response.body
    end
  end
end
