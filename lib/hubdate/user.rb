class Github
  class User
    include Github::Base

    # Generate JSON hash and create new Github::User object through Github::Base
    def self.fetch(user = nil, conn = Github::Connection.new)
      conn = user if user.class == Github::Connection
      user = nil if user.class == Github::Connection
      if user.nil?
        raise ArgumentError.new("Authenticated request required when making calls on logged in user.") unless conn.authenticated?
        responseHash = conn.get("/user")
      else
        responseHash = conn.get("/users/#{user}")
      end
      
      new(responseHash, conn)
    end

    # Define ID because its reserved by ruby
    def id
      @response['id']
    end

    # Define type because its reserved by ruby
    def type
      @response['type']
    end

    # Return a Github::User object for each follower
    def followers
      result = connection.get("/users/#{login}/followers")

      result.map do |follower|
        self.class.new(follower, connection)
      end
    end

    def notifications(params = {})
      Github::Notification.list(params, connection)
    end

    def repos(params = {})
      Github::Repository.list(login, type, params, connection)
    end

    def watchers(type)

      case type
      when :stargazer
        type = "stargazers"
      when :watcher
        type = "subscribers"
      else
        raise StandardError.new("Watcher type must be either :stargazer or :watcher!")
      end

      stargazers_hash = {}
      repos = self.repos.map {|repo| repo.name}

      repos.each do |repo|
        stargazers = connection.get("/repos/#{login}/#{repo}/#{type}")
        stargazers_array = stargazers.map {|gazer| gazer["login"]}

        stargazers_hash[repo.to_s] = stargazers_array
      end

      return stargazers_hash
    end
  end
end
