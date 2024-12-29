require 'octokit'

module Linguist
  def multiple_repos(repos)
    summaries = []
    repos.each do |repo|
      repo = index_repo(repo)
      s = Summary.new repo
      summaries.push(s)
    end
    super_tally = merge_summaries(summaries)
    return super_tally
  end

  def get_remote_repo(git)
    directories = []
    path = Dir.mktmpdir("linguist-#{git}")
    directories.push(path)
    `git clone --quiet -- #{git} #{path}`
    return path
  end

  def index_user(username)
    @directories = []
    user = Octokit.user username
    links = user.rels[:repos].get.data.map(&:html_url)
    repos = links.map(&method(:get_remote_repo))
    s = multiple_repos(repos)
    teardown
    return s
  end

  def index_org(orgname)
    @directories = []
    org = Octokit.org orgname
    links = org.rels[:repos].get.data.map(&:html_url)
    repos = links.map(&method(:get_remote_repo))
    s = multiple_repos(repos)
    teardown
    return s
  end

  def teardown
    @directories.each { |path| FileUtils.remove_entry_secure(path) }
    @directories.clear
  end
end
