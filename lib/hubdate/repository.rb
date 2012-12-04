class Github
  class Repository
    include Github::Base

    # Generate JSON hash and create new Github::Repository object through Github::Base
    def self.fetch(user, name, conn = Github::Connection.new)
      raise ArgumentError.new("Username must be provided. Call user.repo(*) for an authenticated user's repository.") if user.nil?
      raise ArgumentError.new("Repository name must be provided.") if name.nil?

      responseHash = conn.get("/repos/#{user}/#{name}")
      new(responseHash, conn)
    end

    # Do some argument checking and then return an array of repository objects
    def self.list(login, account_type, params = {}, conn = Github::Connection.new)
      conn = params if params.class == Github::Connection
      params = {} if params.class == Github::Connection

      case account_type
      when "User"
        baseUrl = "users"
      when "Organization"
        baseUrl = "orgs"
      else
        raise ArgumentError.new("Unknown account type: #{account_type}.")
      end

      repositories = conn.get("/#{baseUrl}/#{login}/repos", params)

      repositories.map do |repo|
        new(repo, conn)
      end
    end
  end
end
