require 'erb'

module Linguist
  class Describable
    attr_reader :summary

    def initialize(summary)
      @summary = summary
    end

    def describe(template_path)
      template = File.read(template_path)
      renderer = ERB.new(template)
      renderer.result(binding)
    end
  end

  class User < Describable
    def describe(template_path = 'lib/linguist-ext/templates/user.html.erb')
      super(template_path)
    end
  end

  class Org < Describable
    def describe(template_path = 'lib/linguist-ext/templates/org.html.erb')
      super(template_path)
    end
  end

  class Repo < Describable
    def describe(template_path = 'lib/linguist-ext/templates/repo.html.erb')
      super(template_path)
    end
  end
end
