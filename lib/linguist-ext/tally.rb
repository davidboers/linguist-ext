require "linguist"

module Linguist
  class Tally
    attr_reader :language
    attr_reader :bytes
    attr_reader :filecount
    attr_reader :lines
    attr_reader :loc

    def initialize(repo, language)
      @language = language
      if repo.is_a? Linguist::Repository
        bd = repo.languages
        files = repo.breakdown_by_file[language]
      elsif repo.is_a? Hash
        bd = repo
        files = bd[language]["files"]
      end

      if bd[language].nil?
        puts "Could not find that language: #{language}"
      else
        details = bd[language]
      end

      @bytes = details
      @filecount = files.length
      @lines = 0
      @loc = 0

      files.each do |path|
        if !File.exist? path
          puts "No file #{path}."
          next
        end
        blob = Linguist::FileBlob.new(path, Dir.pwd)
        @lines += blob.loc
        @loc += blob.sloc
      end
    end

    def lang_obj
      obj = Language.find_by_name(@language)
      if obj.nil?
        puts "No language object found for #{@language}."
      else
        return obj
      end
    end

    def present(totalbytes = 0)
      if totalbytes == 0
        puts "%-15s %-10s lines: %-5s loc: %-5s" % [@language, @bytes, @lines, @loc]
      else
        share = (self.bytes / totalbytes.to_f * 100).round(2)
        puts "%-15s %-10s %-6s lines: %-5s loc: %-5s" % [@language, @bytes, share, @lines, @loc]
      end
    end

    def merge(tally)
      @bytes += tally.bytes
      @filecount += tally.filecount
      @lines += tally.lines
      @loc += tally.loc
    end
  end
end
