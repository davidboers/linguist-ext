module Linguist
  class Org < Describable
    def initialize(orgname)
      @directories = []
      org = Octokit.org orgname
      links = org.rels[:repos].get.data.map(&:html_url)
      repos = links.map(&method(:get_remote_repo))
      @summary = multiple_repos(repos)
      @directories.each { |path| FileUtils.remove_entry_secure(path) }
      @directories.clear
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