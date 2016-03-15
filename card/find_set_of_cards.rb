require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<MINGLE INSTANCE>.mingle-api.thoughtworks.com/api/v2/projects/<PROJECT>/cards.xml'
OPTIONS = {:access_key_id => '<SIGN IN NAME>', :access_secret_key => '<TOKEN>'}
PARAMS = { :view => "All" }

def http_get(url, params, options={})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  
  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  cards = response.body

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
    Request URL: #{url}
    Response: #{response.code}
    Response Message: #{response.message}
    Response Headers: #{response.to_hash.inspect}
    Response Body: #{response.body}
    ERROR
  end
  
  puts cards 
end

http_get(URL, PARAMS, OPTIONS)