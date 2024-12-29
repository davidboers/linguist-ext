require_relative './helper'
require_relative './myrepos'

class TestUser < Minitest::Test
  include Linguist

  def before_setup
    @directories = []
  end

  def test_multiple_local_repos
    repos = Linguist.myrepos
    puts 'Selected local repos:'
    multiple_repos(repos).present
  end

  def test_user
    puts 'Github user repos:'
    index_user('davidboers').present

    puts 'Github org repos:'
    index_org('NewElectoralCollege').present
  end
end
