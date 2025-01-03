module Linguist
  class Repo < Describable
    def initialize(repopath)
      rugged = Rugged::Repository.new(repopath)
      begin
        repo = Linguist::Repository.new(rugged, rugged.head.target_id)
      rescue Rugged::ReferenceError
        repo = Linguist::Repository.new(rugged, rugged.empty_tree_id)
      end
      @summary = Summary.new repo
      super('repository')
    end

    def make_title
      'Repository breakdown'
    end

    def no_langs
      'There are no programming languages in this repository.'
    end

    def one_lang
      "This repository is written in #{main_lang.name}."
    end

    def multiple_langs
      big_langs = summary.big_languages
      "This repository is written in #{merge_langs(big_langs)}."
    end
  end
end