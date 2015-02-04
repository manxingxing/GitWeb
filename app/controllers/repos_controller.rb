# -*- coding: utf-8 -*-
class ReposController < ApplicationController
  skip_before_action :load_repo, only: [:index]
  before_action :load_ref, only: [:tree, :blob, :commits, :edit_file, :update_file]
  before_action :load_blob, only: [:blob, :edit_file, :update_file]

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
  end

  def edit_file
  end

  def update_file
    index = @repo.repository.index
    index.read_tree(@branch.target.tree)

    new_blob = @repo.write(params[:content].delete!("\r"), :blob)
    index.add({path: params[:path], oid: new_blob, mode: 0100644})
    new_tree = index.write_tree(@repo.repository)

    options = {tree: new_tree, message: params[:message]}
    current_user = {
      email: Rugged::Config.global['user.email'],
      name:  Rugged::Config.global['user.name'],
      time: Time.now
    }
    options[:author] = current_user
    options[:committer] = current_user
    options[:parents] = @repo.empty? ? [] : [ @branch.target ]
    options[:update_ref] = @branch.canonical_name

    Rugged::Commit.create(@repo.repository, options)

    redirect_to repo_blob_path(repo: params[:repo], ref: params[:ref], path: params[:path])
  end


  def commits
    @commits = []
    @finished = true
    per_page = 15
    params[:page] = (params[:page] || 1).to_i

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
    @commit = @repo.lookup params[:oid]

    if @commit.parents.empty?
      @diff = @commit.diff(reverse: true)
    else
      @diff = @commit.parents[0].diff(@commit)
    end
    @diff.find_similar!
  end

private
  def load_ref
    params[:ref] ||= 'master'
    @branch = @repo.branches[params[:ref]]
  end

  def load_blob
    @blob = @repo.blob_at(@branch.target.oid, params[:path])
  end
end
