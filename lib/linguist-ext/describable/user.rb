module Linguist
  class User < Describable
    include MultipleRepos

    def initialize(options = {})
      copy_repos(options, 'user')
      super('user')
    end

    def make_title
      'User breakdown'
    end

    def no_langs
      'There are no programming languages in this user\'s repositories.'
    end

    def one_lang
      "This user writes in #{main_lang.name}."
    end

    def multiple_langs
      langs = merge_langs(summary.tallies[0..2].map(&:language))
      "This user\'s preferred languages are #{langs}."
    end
  end
end