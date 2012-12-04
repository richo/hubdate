class Github
  class Notification
    include Github::Base

    # Generate JSON hash and create new Github::Repository object through Github::Base
    def self.fetch(conn = Github::Connection.new)
      raise ArgumentError.new("You must be authenticated to retrieve this information!") if !connection.authenticated?

      responseHash = conn.get("/notifications")
      new(responseHash, conn)
    end

    def message
      subject["title"]
    end

    def type
      subject["type"]
    end

    # Do some argument checking and then return an array of repository objects
    def self.list(params = {}, conn = Github::Connection.new)
      conn = params if params.class == Github::Connection
      params = {} if params.class == Github::Connection

      notifications = conn.get("/notifications", params)

      notifications.map do |notification|
        new(notification, conn)
      end
    end
  end
end
