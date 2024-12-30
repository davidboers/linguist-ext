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
    path = Dir.mktmpdir("linguist-#{git}")
    @directories.push(path)
    `git clone --quiet -- #{git} #{path}`
    return path
  end

  def index_user(username, access_token = nil)
    @directories = []
    if access_token.nil?
      user = Octokit.user username
      links = user.rels[:repos].get.data.map(&:html_url)
    else
      client = Octokit::Client.new access_token: access_token
      links = client.repos(client.user, affiliation: 'owner').map(&:html_url)
    end
    repos = links.map(&method(:get_remote_repo))
    s = multiple_repos(repos)
    @directories.each { |path| FileUtils.remove_entry_secure(path) }
    @directories.clear
    return s
  end

  def index_org(orgname)
    @directories = []
    org = Octokit.org orgname
    links = org.rels[:repos].get.data.map(&:html_url)
    repos = links.map(&method(:get_remote_repo))
    s = multiple_repos(repos)
    @directories.each { |path| FileUtils.remove_entry_secure(path) }
    @directories.clear
    return s
  end
end
