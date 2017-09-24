class ProjectController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show]

  def index
    # Ensure unique URL
    unless request.path == root_path
      redirect_to root_path
      return
    end

    # Ensure access
    authorize UserProject

    @projects = UserProject.of_user(current_user).ordered
  end

  def show
    # Ensure access
    authorize @project
  end

  private
    def set_project
      @project = UserProject.of_user(current_user).find(params[:id])
    end
end
