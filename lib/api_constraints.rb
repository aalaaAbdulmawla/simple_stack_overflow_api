class ApiConstraints
	def initialize(options)
		@version = options[:version]
		@default = options[:default]
	end

	def matches?(req)
		@default || req.headers['Accept'].include?("application/vnd.api_stackOverFlow.v#{@version}")
	end
end