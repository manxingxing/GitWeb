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
    @commits = []
    @finished = true
    per_page = 15
    params[:page] = (params[:page] || 1).to_i
    skipped = 0

    walker = Rugged::Walker.new(@repo.repository)
    walker.sorting(Rugged::SORT_DATE)
    walker.push @branch.target

    walker.each_with_index do |commit, index|
      next if index + 1 <= per_page * (params[:page] - 1)

      if @commits.size >= per_page
        @finished = false
        break
      else
        @commits.push commit
      end
    end

    @commits = @commits.group_by do |commit|
      commit.time.strftime("%Y-%m-%d")
    end
  end

  def commit

  end

private
  def load_ref
    params[:ref] ||= 'master'
    @branch = @repo.branches[params[:ref]]
  end
end
