require_relative './helper'

class TestRepo < Minitest::Test
  include Linguist

  def normalize_path(input)
    return "#{Dir.pwd}/#{input}"
  end

  def get_json
    jsonpath = normalize_path '/test/breakdown.json'
    results = from_json(jsonpath)
    return results
  end

  def summary
    results = get_json
    s = Summary.new results
    s.present

    puts
    if s.big_languages.empty?
      puts 'No big languages found.'
    end

    puts "Size: #{s.size}"
    puts 'Big languages: %s' % merge_langs(s.big_languages)
    return s
  end

  def test_tally_type
    s = summary
    puts s.tally_by_type
  end
end
