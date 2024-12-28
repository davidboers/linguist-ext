module Linguist
  # join_langs []                       == ''
  # join_langs ['Ruby']                 == 'Ruby'
  # join_langs ['C++', 'C']             == 'C++ and C'
  # join_langs ['C#', 'Java', 'Python'] == 'C#, Java and Python'
  def merge_langs(langs = [])
    if langs.empty? || langs.nil?
      return ""
    elsif langs.length == 1
      return langs[0]
    elsif langs.length == 2
      return langs.join(" and ")
    elsif langs.size > 2
      penultimate = langs[-1]
      langs = langs.split(penultimate)
      by_comma = langs[0]
      by_and = [penultimate] + langs[1]
      return by_comma.join(", ") + ", " + merge_langs(by_and)
    end
  end
end
