class ReposController < ApplicationController
  before_action :load_repo, except: [:index]

  def index
    @repos = Repo.repos
  end

  def show
    @tree = @repo.head.target.tree
    @branches = @repo.branches
  end

  def tree

  end

  def blob

  end

  def commits

  end

private
  def load_repo
    @repo = Repo.find_by_name params[:id]
  end
end
