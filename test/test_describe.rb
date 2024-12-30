require_relative './helper'

class TestDescribe < Minitest::Test
  include Linguist

  def test_org
    s = index_org('NewElectoralCollege')
    org = Org.new(s)
    File.write('test/descriptions/org.html', org.describe)
  end

  def test_repo
    repo = index_repo('.')
    s = Summary.new repo
    repo = Repo.new(s)
    File.write('test/descriptions/repo.html', repo.describe)
  end

  def test_user
    s = index_user('davidboers')
    user = User.new(s)
    File.write('test/descriptions/user.html', user.describe)
  end
end
