require 'erb'

module Linguist
  class Describable
    include Helper

    attr_reader :summary
    attr_accessor :noun
    attr_reader :main_lang

    def initialize(summary, noun)
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

    def describe
      template_path = 'lib/linguist-ext/templates/description.html.erb'
      template = File.read(template_path)
      renderer = ERB.new(template)
      renderer.result(binding)
    end
  end

  class User < Describable
    def initialize(summary)
      super(summary, 'user')
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
    def initialize(summary)
      super(summary, 'organization')
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
    def initialize(summary)
      super(summary, 'repository')
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
