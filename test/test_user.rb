require_relative "./helper"
require_relative "./myrepos"
require "octokit"

class TestUser < Minitest::Test
  include Linguist

  def before_setup
    @directories = []
  end

  def multiple_repos(repos)
    summaries = []
    repos.each do |repo|
      puts repo
      repo = index_repo(repo)
      s = Summary.new repo
      summaries.push(s)
    end
    super_tally = merge_summaries(summaries)
    super_tally.present
  end

  def test_multiple_local_repos
    return ""
    repos = Linguist.myrepos
    multiple_repos(repos)
  end

  def get_remote_repo(git)
    path = Dir.mktmpdir("linguist-#{git}")
    @directories.push(path)
    `git clone --quiet -- #{git} #{path}`
    return path
  end

  def test_user
    # Public repos of user:
    #user = Octokit.user 'davidboers'

    # Public repos of org:
    user = Octokit.org 'NewElectoralCollege'

    links = user.rels[:repos].get.data.map { |repo| repo.html_url }
    repo_paths = links.map { |link| get_remote_repo(link) }
    multiple_repos(repo_paths)
    @directories.each { |path| FileUtils.remove_entry_secure(path) }
    @directories.clear
  end
end
