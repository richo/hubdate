class Github
  module Base
    attr_reader :response, :connection

    # Initialize module by gathering JSON hash and connection
    def initialize(responseHash, conn = Github::Connection.new)
      @connection = conn
      @response = responseHash
    end

    # If method doesnt exist, check if the id is a response key and if so return the value
    def method_missing(id, *args)
      unless @response && @response.keys.include?(id.id2name)
        raise NoMethodError.new("Undefined method #{id.id2name} for #{self}: #{self.class}.")
      end

      @response[id.id2name]
    end
  end
end