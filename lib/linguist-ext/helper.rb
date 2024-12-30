module Linguist
  module Helper
    # merge_langs []                       == ''
    # merge_langs ['Ruby']                 == 'Ruby'
    # merge_langs ['C++', 'C']             == 'C++ and C'
    # merge_langs ['C#', 'Java', 'Python'] == 'C#, Java and Python'
    def merge_langs(langs = [])
      if langs.empty? || langs.nil?
        return ''
      elsif langs.length == 1
        return langs[0]
      elsif langs.length == 2
        return langs.join(' and ')
      elsif langs.size > 2
        by_comma = langs[0..-3]
        by_and = langs[-2..-1]
        return by_comma.join(', ') + ', ' + merge_langs(by_and)
      end
    end
  end
end
