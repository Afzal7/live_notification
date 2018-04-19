require "live_notifications/version"
require "live_notifications/engine"
require "live_notifications/w3sockets"

module LiveNotifications
  class W3socket	
		def self.init
			@url = 'https://www.w3sockets.com'
			# @url = 'http://localhost:3000'
			@grant_type = 'client_credentials'
			
			@w3sockets_config = YAML.load_file(Rails.root.to_s + '/config/w3sockets_config.yml')[Rails.env]
			@public_key = @w3sockets_config['public_key']
			@secret_key = @w3sockets_config['secret_key']
			@access_token = W3socketToken.first.try(:token)
		end

		def self.get_access_token
			begin
				
				request = RestClient.post(@url+'/oauth/token', {client_id: @public_key, client_secret: @secret_key, grant_type: @grant_type})
				@access_token = JSON.parse(request.body)['access_token']
				
				W3socket.update_token
				
				return {success: true}
			
			rescue => e
				return {success: false, response: JSON.parse(e.as_json['response'].body), response_code: e.as_json['initial_response_code']}
			end
		end

		def self.update_token
			# w3sockets_configurations = YAML.load_file(Rails.root.to_s + '/config/w3sockets_config.yml')
			# w3sockets_configurations[Rails.env]['access_token'] = @access_token
			# output = YAML.dump w3sockets_configurations
			# File.write(Rails.root.to_s + '/config/w3sockets_config.yml', output)
			if W3socketToken.first.present?
				W3socketToken.first.update_attributes(token: @access_token)
			else
				W3socketToken.create(token: @access_token)
			end
		end

		def self.push (channel, event, message)
			W3socket.init
			
			if @access_token.blank?
				unless W3socket.get_access_token[:success]
					return W3socket.get_access_token
				end
			end

			@data = {channel: "#{@public_key}-#{channel}", event: event, message: message}
			p @data
			
			begin
				
				request = RestClient.post(@url+'/api/v1/push/notify', {access_token: @access_token, data: @data})
				
				if request.present?
					return JSON.parse(request.body)
				else
					return {success: false, response: 'Error! Unable to send data.'}
				end
			
			rescue => e
				
				if e.as_json['initial_response_code'] == 401
					W3socketToken.destroy_all
					W3socket.push(channel, event, message)
				else
					return {success: false, response: JSON.parse(e.as_json['response'].body), response_code: e.as_json['initial_response_code']}
				end
			
			end
		end
	end

end
