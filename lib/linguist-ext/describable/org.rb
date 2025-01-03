module Linguist
  class Org < Describable
    include MultipleRepos

    def initialize(orgname)
      copy_repos({:username => orgname}, 'organization')
      super('organization')
    end

    def make_title
      'Organization breakdown'
    end

    def no_langs
      'There are no programming languages in this organization\'s repositories.'
    end

    def one_lang
      "This organization writes in #{main_lang.name}."
    end

    def multiple_langs
      langs = merge_langs(summary.tallies[0..2].map(&:language))
      "This organization\'s preferred languages are #{langs}."
    end
  end
end