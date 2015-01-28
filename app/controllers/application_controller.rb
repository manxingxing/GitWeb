class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :load_repo

private
  def load_repo
    @repo = Repo.find_by_name params[:repo] if params[:repo]
  end
end
