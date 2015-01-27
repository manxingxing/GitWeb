class Repo
  MONITORED_DIR = File.join(Rails.root, 'repos')

  def initialize path
    @name = File.basename path, '.git'
    @repository = (Rugged::Repository.new(path) rescue nil)
  end

  attr_accessor :name, :repository

  def nil?
    @repository.nil?
  end

  class << self; attr_reader :repos; end

  def self.load_repos
    @repos = []
    Dir.glob(File.join(MONITORED_DIR, '*')).each do |entry|
      repo = self.new(entry)
      @repos.push(repo) unless repo.nil?
    end
    @repos
  end
  self.load_repos

  def self.find_by_name name
    repos.detect {|repo| repo.name.downcase == name.strip.downcase}
  end

  def method_missing method
    repository.send method
  end

  def to_param
    name
  end
end
