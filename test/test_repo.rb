require_relative './helper'

class TestRepo < Minitest::Test
  include Linguist
  include Helper

  def normalize_path(input)
    return "#{Dir.pwd}/#{input}"
  end

  def get_json
    jsonpath = normalize_path '/test/breakdown.json'
    results = from_json(jsonpath)
    return results
  end

  def summary(s)
    s.present

    puts
    if s.big_languages.empty?
      puts 'No big languages found.'
    end

    puts "Size: #{s.size}"
    puts "Big languages: #{merge_langs(s.big_languages)}"
  end

  def test_tally_type
    repo = Repo.new('.')
    s = repo.summary
    summary(s)
    puts s.tally_by_type
  end
end
