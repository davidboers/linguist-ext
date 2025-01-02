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

    def format_number(number)
      number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
    end

    def format_bytes(bytes)
      kb = 1000
      mb = kb * 1000
      gb = mb * 1000
      tb = gb * 1000
      if bytes < kb
        return "#{bytes}"
      elsif bytes < mb
        return "#{(bytes / kb)} KB"
      elsif bytes < gb
        return "#{(bytes / mb)} MB"
      elsif bytes < tb
        return "#{(bytes / mb)} GB"
      else
        return "#{(bytes / tb)} TB"
      end
    end
  end
end
