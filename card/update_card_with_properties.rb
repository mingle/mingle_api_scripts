require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://INSTANCE.mingle-api.thoughtworks.com/api/v2/projects/PROJECT/cards/1.xml'
OPTIONS = {:access_key_id => 'SIGN IN NAME', :access_secret_key => 'KEY'}
PARAMS = {
  :card => {
      :name => "New Title",
      :type => "Story",
      :description => "Testing",
      :properties => [{ :name => "Status",:value => "New"}, { :name => "Owner",:value => "esnyder"}]
    }
  }

def http_put(url, params, options={})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  body = params.to_json

  request = Net::HTTP::Put.new(uri.request_uri)
  request.body = body
  request['Content-Type'] = 'application/json'
  request['Content-Length'] = body.bytesize

  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  card = response.body
  
  if response.code.to_i > 300
      raise StandardError, <<-ERROR
      Request URL: #{url}
      Response: #{response.code}
      Response Message: #{response.message}
      Response Headers: #{response.to_hash.inspect}
      Response Body: #{response.body}
      ERROR
  end
  puts card
end

http_put(URL, PARAMS, OPTIONS)
