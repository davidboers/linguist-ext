require_relative 'tally'

module Linguist
  # Must summarize a single repo.
  class Summary
    attr_reader :tallies

    # Initialize a summary using a bd from a .json file
    def initialize(bd = {})
      @tallies = []
      languages = []
      if bd.is_a? Hash
        languages = bd
      elsif bd.is_a? Linguist::Repository
        languages = bd.languages
      end
      languages.each do |language, size|
        @tallies.append Tally.new(bd, language)
      end
    end

    def present
      totalbytes = self.totalbytes
      @tallies.sort_by(&:bytes).reverse.each do |tally|
        tally.present(totalbytes)
      end
    end

    def totalbytes
      @tallies.map(&:bytes).sum
    end

    # Returns list of languages with at least 10% total bytes
    def big_languages
      threshold = self.size / 10
      return @tallies.select { |t| t.bytes >= threshold }.map(&:language)
    end

    def tally_by_type
      types = [:data, :markup, :programming, :prose]
      tally = {}
      types.each do |type|
        tally[type] = @tallies.select { |t| t.lang_obj.type == type }.map(&:bytes).sum
      end
      return tally
    end

    def size
      return @tallies.map(&:bytes).sum
    end

    def key?(lang)
      @tallies.each do |tally|
        if tally.language == lang
          return true
        end
      end
      return false
    end

    def add(tally)
      @tallies.push(tally)
    end

    def get(lang)
      @tallies.each do |tally|
        if tally.language == lang
          return tally
        end
      end
    end

    def merge(j)
      j.tallies.each do |tally|
        lang = tally.language
        if !key? lang
          add(tally)
        else
          get(lang).merge(tally)
        end
      end
    end

    def otherize
      threshold = 0.01
      t = @tallies.select { |t| t.bytes / totalbytes.to_f >= threshold }
      o = @tallies.select { |t| t.bytes / totalbytes.to_f <  threshold }
      if o.length == 0
        return t
      end
      other_tally = OtherLangs.new o
      t.push other_tally
      return t
    end
  end
end
