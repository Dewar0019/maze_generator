class MazesController < ApplicationController
  def create
    render status: 201, json: Maze.create, except: :blockers
  end

  def check
    if coordinate_params[:y].nil? || coordinate_params[:x].nil?
      render status: 400, json: "missing coordinates"
      return
    end

    @maze = Maze.find(params[:id])
    render status: 200, json: @maze.is_valid_space(coordinate_params[:y].to_i, coordinate_params[:x].to_i) ? "valid" : "invalid"
  end

  def solve
    solutions_json = solution_params[:solution]
    if solutions_json.nil?
      render status: 400, json: "missing solutions"
      return
    end

    parsed_solutions = JSON.parse(solutions_json)

    if any_solutions_invalid?(parsed_solutions)
      render status: 400, json: "invalid solutions format"
      return
    end

    @maze = Maze.find(params[:id])
    solution_results = @maze.solve(parsed_solutions)
    render status: 200, json: solution_results ? "correct" : "incorrect"
  end

  private

  def any_solutions_invalid?(solution)
    solution.any? { |ans| !ans.key?("x") || !ans.key?("y")}
  end

  def maze_params
    params.require(:maze).permit(:id, :width, :height)
  end

  def coordinate_params
    params.require(:maze).permit(:x, :y)
  end

  def solution_params
    params.permit(:solution)
  end
end
