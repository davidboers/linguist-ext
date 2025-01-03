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
      if @verbose
        puts "Cloning #{git} (#{@repo_tally}/#{@total_repos})"
        @repo_tally += 1
      end
      path = Dir.mktmpdir("linguist-#{git}")
      @directories.push(path)
      `git clone --quiet -- #{git} #{path}`
      return path
    end
  end
end
