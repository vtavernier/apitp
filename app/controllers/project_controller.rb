class ProjectController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show]

  def index
    # Ensure unique URL
    unless request.path == root_path
      redirect_to root_path
      return
    end

    @projects = UserProject.of_user(current_user)
  end

  def show
  end

  private
    def set_project
      @project = UserProject.find(params[:id])
    end
end
