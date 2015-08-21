require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'nokogiri'

URL = 'https://<YOUR MINGLE INSTANCE>.mingle-api.thoughtworks.com/api/v2/users.xml'
OPTIONS = {:access_key_id => '<SIGN IN NAME>', :access_secret_key => '<SECRET KEY>'}

def http_get(url, options={})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  users = response.body

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
    Request URL: #{url}
    Response: #{response.code}
    Response Message: #{response.message}
    Response Headers: #{response.to_hash.inspect}
    Response Body: #{response.body}
    ERROR
  end
  return users
end

def extract_active_users
  all_users = Nokogiri::XML(http_get(URL, OPTIONS))
  all_users.search('//user').each do |user|
    active_user = user.xpath('activated')
    if active_user.text == 'true'
      puts user
    end
  end
end

extract_active_users