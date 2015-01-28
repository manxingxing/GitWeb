class ReposController < ApplicationController
  skip_before_action :load_repo, only: [:index]
  before_action :load_ref, only: [:tree, :blob, :commits]

  def index
    @repos = Repo.repos
  end

  def tree
    root_tree = @branch.target.tree

    if params[:path].present?
      entry = (root_tree.path(params[:path]) rescue nil)
      @tree = entry && entry[:type].eql?(:tree) ? @repo.lookup(entry[:oid]) : root_tree
    else
      @tree =root_tree
    end
  end

  def blob
    @blob = @repo.blob_at(@branch.target.oid, params[:path])
  end

  def commits

  end

  def commit

  end

private
  def load_ref
    params[:ref] ||= 'master'
    @branch = @repo.branches[params[:ref]]
  end
end
