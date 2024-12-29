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
      total = 0
      @tallies.each do |tally|
        total += tally.bytes
      end
      return total
    end

    # Returns list of languages with at least 10% total bytes
    def big_languages
      threshold = self.size / 10
      return @tallies.select { |t| t.bytes >= threshold }.map { |t| t.language }
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
  end

  def merge_summaries(summaries = [])
    out = Summary.new
    summaries.each do |summary|
      summary.tallies.each do |tally|
        lang = tally.language
        if !out.key? lang
          out.add(tally)
        else
          out.get(lang).merge(tally)
        end
      end
    end
    return out
  end
end
