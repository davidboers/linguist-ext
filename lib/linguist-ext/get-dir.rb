require 'json'
=begin pending fix of linguist
require 'linguist'
require 'rugged'

def index_repo(repopath)
  rugged = Rugged::Repository.new(repopath)
  repo = Linguist::Repository.new(rugged, rugged.head.target_id)
  return repo
end
=end

module Linguist

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