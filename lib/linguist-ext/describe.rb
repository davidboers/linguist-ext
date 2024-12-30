require 'erb'
require 'octokit'

module Linguist
  class Describable
    include Helper

    attr_reader :summary
    attr_accessor :noun
    attr_reader :main_lang

    def initialize(noun)
      @summary = summary
      @noun = noun
      @summary.tallies.sort_by! { |t| -t.bytes }
      unless summary.tallies.empty?
        @main_lang = summary.tallies.first
      end
    end

    def byte_share(bytes)
      (bytes / summary.totalbytes.to_f * 100).round 2
    end

    def main_msg
      case summary.tallies.length
      when 0
        no_langs
      when 1
        one_lang
      else
        multiple_langs
      end
    end

    def make_title
      raise NotImplementedError
    end

    def maj
      largest_shr = byte_share(main_lang.bytes)
      if largest_shr >= 50 && largest_shr != 100
        "Most (#{largest_shr}%) of this #{noun}'s code is written in #{main_lang.language}."
      else
        ''
      end
    end

    def no_langs
      raise NotImplementedError
    end

    def one_lang
      raise NotImplementedError
    end

    def multiple_langs(msg)
      raise NotImplementedError
    end

    def index
      raise NotImplementedError
    end

    def describe
      template_path = 'lib/linguist-ext/templates/description.html.erb'
      template = File.read(template_path)
      renderer = ERB.new(template)
      renderer.result(binding)
    end

    def get_remote_repo(git)
      path = Dir.mktmpdir("linguist-#{git}")
      @directories.push(path)
      `git clone --quiet -- #{git} #{path}`
      return path
    end

    def multiple_repos(repos)
      summary = Summary.new
      repos.each do |repo|
        repo = Repo.new repo
        summary.merge(repo.summary)
      end
      return summary
    end
  end

  class User < Describable
    def initialize(username, access_token = nil)
      @directories = []
      if access_token.nil?
        user = Octokit.user username
        links = user.rels[:repos].get.data.map(&:html_url)
      else
        client = Octokit::Client.new access_token: access_token
        links = client.repos(client.user, affiliation: 'owner').map(&:html_url)
      end
      repos = links.map(&method(:get_remote_repo))
      @summary = multiple_repos(repos)
      @directories.each { |path| FileUtils.remove_entry_secure(path) }
      @directories.clear
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
