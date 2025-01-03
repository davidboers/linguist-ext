module Linguist
  module MultipleRepos
    def copy_repos(options = {}, noun)
      @directories = []
      if !options[:access_token].nil?
        client = Octokit::Client.new :access_token => options[:access_token]
        repos = client.repos(client.user, affiliation: 'owner')
      elsif !options[:netrc].nil? && options[:netrc]
        netrc_file = options[:netrc_file].nil? ? "~/.netrc" : options[:netrc_file] 
        if !File.exist? netrc_file
          puts "#{netrc_file} does not exist."
        end
        client = Octokit::Client.new :netrc => true, :netrc_file => netrc_file
        repos = client.repos(client.user, affiliation: 'owner')
      elsif !options[:username].nil?
        user = if noun == 'user'
          Octokit.user options[:username]
        elsif noun == 'organization'
          Octokit.org options[:username]
        end
        repos = user.rels[:repos].get.data
      else 
        puts 'No authorization or username provided.'
      end
      repos = repos.map(&:html_url).map(&method(:get_remote_repo))
      @summary = multiple_repos(repos)
      @directories.each { |path| FileUtils.remove_entry_secure(path) }
      @directories.clear
    end
  end
end