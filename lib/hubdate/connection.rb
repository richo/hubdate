class Github
  class Connection
    attr_accessor :user # Allows us to call for the connections user later
    attr_reader :pass, :token
   
    # Check for argument errors and format credentials
    def initialize(args={})
      raise ArgumentError.new("Github::Connection does not take any arguments of type #{args.class}.") unless args.is_a?(Hash)
      
      args.keys.each do |key|
        raise ArgumentError.new("Unknown option '#{key}'.") unless [:user, :pass, :token].include? key
      end

      if args.keys.include?(:user) || args.keys.include?(:pass)
        unless args.keys.include?(:user) && args.keys.include?(:pass)
          raise ArgumentError.new("When using basic authentication, both :user and :pass are required.")
        end
      end

      if args.keys.include?(:token)
        if args.keys.include?(:user) || args.keys.include?(:pass)
          raise ArgumentError.new("Both OAuth parameters and basic authenctication parameters have been previded.")
        end
      end

      @user = args[:user]
      @pass = args[:pass]
      @token = args[:token]

      @server = "api.github.com"

      if !@token.nil?
        @creds = {:token => @token}
      elsif !@user.nil?
        @creds = {:user => @user, :pass => @pass}
      elsif @token.nil? && @user.nil?
        @creds = {}
      end
    end

    # Check is user is authenticated
    def authenticated?
      if (user && pass) || token
        true
      else
        false
      end
    end
    
    # Send HTTP Get request
    def get(path, params = {}, creds = @creds, server = @server)
      path = linkPath(path, params) if params != {}
      path = linkPath(path, params, creds[:token]) if params != {} && creds.keys.include?(:token)

      http = Net::HTTP.new(server, 443)
      req = Net::HTTP::Get.new(path)
      http.use_ssl = true
      req.basic_auth creds[:user], creds[:pass] if creds.keys.include?(:user)
      response = http.request(req)
      return JSON.parse(response.body)
    end

    def post(path, params={}, creds = @creds, server = @server)
      path = linkPath(path, params, creds[:token]) if params != {} && creds.keys.include?(:token)
      
      http = Net::HTTP.new(server, 443)
      req = Net::HTTP::Post.new(path)
      http.use_ssl = true
      req.body = params.to_json
      req.basic_auth creds[:user], creds[:pass] if creds.keys.include?(:user)
      response = http.request(req)
      return JSON.parse(response.body)
    end

    def edit
    end

    def delete
    end

    private

      # Method used to link multiple parameters with a base path
    def linkPath(path, params, token = nil)
      param1 = params.shift
      paramString = "?#{param1[0].to_s}=#{param1[1]}"

      params.each do |name, value|
        paramString += "&&#{name.to_s}=#{value}"
      end

      paramString += "&&#{token}" unless token.nil?
      paramString = path + paramString
    end
  end
end
