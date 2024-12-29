require 'json'
require 'linguist'
require 'rugged'

module Linguist
  def index_repo(repopath)
    rugged = Rugged::Repository.new(repopath)
    repo = Linguist::Repository.new(rugged, rugged.head.target_id)
    return repo
  end

  def ignore_to_regex(ignore)
    return "\\A" + ignore.gsub('.', "\\.").gsub('*', '.*') + "\\z"
  end

  def read_git_ignore(path)
    expressions = []
    ignore_file = File.read(path).split
    ignore_file.each do |line|
      line = line.gsub(/#.*/, '')
      unless line.strip.length == 0
        expressions.push ignore_to_regex(line)
      end
    end
    return expressions
  end

  def ignore_paths(paths, excl_list)
    return paths.select { |path| !excl_list.any? { |excl| !!(path.match excl) } }
  end

  def index_dir(dirpath, excl_list = [])
    blobs = []
    if !File.directory? dirpath
      puts "#{dirpath} is not a directory."
    else
      subpaths = Dir.entries(dirpath)
      if subpaths.include? '.gitignore'
        excl_list.concat read_git_ignore("#{dirpath}/.gitignore")
      end
      subpaths = ignore_paths(subpaths, excl_list)
      subpaths.each do |subpath|
        subpath = "#{dirpath}/#{subpath}"
        if File.file? subpath
          blob = Linguist::FileBlob.new(subpath, dirpath)
          unless !blob.language or blob.language.type != :programming
            blobs.push(blob)
          end
        elsif File.directory? subpath
          subblobs = index_dir(subpath, excl_list.map(&:clone))
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
