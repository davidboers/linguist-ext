require_relative "./helper"
require_relative "./myrepos"

class TestUser < Minitest::Test
  include Linguist

  def test_multiple_repos
    repos = Linguist.myrepos
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
end
