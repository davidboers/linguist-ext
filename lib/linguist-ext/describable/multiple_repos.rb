module Linguist
  module MultipleRepos
    def copy_repos(options = {}, noun)
      @directories = []
      if !options[:access_token].nil?
        client = Octokit::Client.new :access_token => options[:access_token]
        thing = if noun == 'user'
            client.user
          elsif noun == 'organization'
            client.org
          end
        repos = client.repos(thing, affiliation: 'owner')
      elsif !options[:netrc].nil? && options[:netrc]
        netrc_file = options[:netrc_file].nil? ? '~/.netrc' : options[:netrc_file]
        if !File.exist? netrc_file
          puts "#{netrc_file} does not exist."
        end
        client = Octokit::Client.new :netrc => true, :netrc_file => netrc_file
        thing = if noun == 'user'
            client.user
          elsif noun == 'organization'
            client.org
          end
        repos = client.repos(client.user, affiliation: 'owner')
      elsif !options[:username].nil?
        thing = if noun == 'user'
            Octokit.user options[:username]
          elsif noun == 'organization'
            Octokit.org options[:username]
          end
        repos = thing.rels[:repos].get.data
      else
        puts 'No authorization or username provided.'
      end

      @verbose = options[:verbose].nil? ? false : options[:verbose]
      if !@verbose && repos.length > 40
        puts 'More than 40 repos detected. Enabling verbose mode.'
        @verbose = true
      end

      if @verbose
        puts "#{repos.length} repositories detected."
        @total_repos = repos.length
        @repo_tally = 1
      end

      repos = repos.map(&:html_url).map(&method(:get_remote_repo))
      @summary = multiple_repos(repos)
      @directories.each { |path| FileUtils.remove_entry_secure(path) }
      @directories.clear
    end

    def multiple_repos(repos)
      summary = Summary.new
      repos.each do |repo|
        repo = Repo.new repo
        summary.merge(repo.summary)
      end
      return summary
    end
  end
end
