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
      @tallies.sort_by { |t| t.bytes }.reverse.each do |tally|
        tally.present
      end
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
        tally[type] = @tallies.select { |t| t.lang_obj.type == type }.map { |t| t.bytes }.sum
      end
      return tally
    end

    def size
      return @tallies.map { |t| t.bytes }.sum
    end
  end
end