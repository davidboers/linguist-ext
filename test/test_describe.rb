require_relative './helper'

class TestDescribe < Minitest::Test
  include Linguist

  def test_org
    org = Org.new('NewElectoralCollege')
    File.write('test/descriptions/org.html', org.describe)
  end

  def test_repo
    repo = Repo.new('.')
    File.write('test/descriptions/repo.html', repo.describe)
  end

  def test_user
    user = User.new('davidboers')
    File.write('test/descriptions/user.html', user.describe)
  end
end
