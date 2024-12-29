require "json"
require "linguist"
require "rugged"

module Linguist
  def index_repo(repopath)
    rugged = Rugged::Repository.new(repopath)
    repo = Linguist::Repository.new(rugged, rugged.head.target_id)
    return repo
  end

  def index_dir(dirpath)
    blobs = []
    if !File.directory? dirpath
      puts "#{dirpath} is not a directory."
    else
      subpaths = Dir.entries(dirpath)
      excl_list = ['.', '..', '.git', 'node_modules']
      excl_list.each do |excl|
        subpaths.delete excl
      end
      subpaths.each do |subpath|
        subpath = "#{dirpath}/#{subpath}"
        if File.file? subpath
          blob = Linguist::FileBlob.new(subpath, dirpath)
          unless !blob.language
            blobs.push(blob)
          end
        elsif File.directory? subpath
          subblobs = index_dir(subpath)
          blobs.concat(subblobs)
        end
      end
    end
    return blobs
  end

  def merge_blobs(blobs = [])
    out = Summary.new
    blobs.each do |blob|
      lang = blob.language
      tally = Tally.new(blob, lang)
      if !out.key? lang
        out.add(tally)
      else
        out.get(lang).merge(tally)
      end
    end
    return out
  end

  def from_json(jsonpath)
    if !File.exist? jsonpath
      puts "#{jsonpath} does not exist. Here is the pwd: #{Dir.pwd}"
    elsif !File.file? jsonpath
      puts "#{jsonpath} is not a file."
    else
      file = File.open jsonpath
      results = JSON.load file
      file.close
      return results
    end
  end
end
