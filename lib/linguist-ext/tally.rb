require 'linguist'

module Linguist
  class Tally
    attr_reader :language
    attr_reader :bytes
    attr_reader :filecount
    attr_reader :lines
    attr_reader :loc

    def initialize(repo, language)
      @language = language
      if false#repo.is_a? Linguist::Repository
        bd = repo.languages
        files = repo.breakdown_by_file[language]
      else
        bd = repo
        files = bd[language]['files']
      end
      if bd[language].nil?
        puts "Could not find that language: #{language}"
      else
        details = bd[language]
      end
      @bytes = details['size']
      @filecount = files.length
      @lines = 0
      @loc = 0
=begin
      files.each do |path|
        blob = Linguist::FileBlob.new(path, Dir.pwd)
        @lines += blob.loc
        @loc += blob.sloc
      end
=end
    end

    def lang_obj
      return Language.find_by_name(@language)
    end

    def present
      puts '%-10s %-10s lines: %-5s loc: %-5s' % [@language, @bytes, @lines, @loc]
    end
  end
end