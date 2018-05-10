class MazeController < ApplicationController
  def create
    render status: 201, json: Maze.create
  end

  def check
    @maze = Maze.find(params[:id])
    if @maze.check(coordinate_params[:x], coordinate_params[:y])
      render status: 200, json: "valid"
    else
      render status: 400, json: "invalid"
    end
  end

  def solve
    @maze = Maze.find(params[:id])
    render status: 200, json: @maze.solve(solution_params[:_json])
  end

  private

  def maze_params
    params.require(:maze).permit(:id, :width, :height)
  end

  def coordinate_params
    params.require(:maze).permit(:x, :y)
  end

  def solution_params
    params.permit(_json: [:x, :y])
  end
end
