require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'nokogiri'

URL = 'https://<instance>.mingle-api.thoughtworks.com/api/v2/projects/<project identifier>/users.xml'
OPTIONS = {:access_key_id => "<username>", :access_secret_key => '<HMAC key>'}


def http_get(url, options={})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  team_members = response.body

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
    Request URL: #{url}
    Response: #{response.code}
    Response Message: #{response.message}
    Response Headers: #{response.to_hash.inspect}
    Response Body: #{response.body}
    ERROR
  end
  return team_members
end

def extract_admin_users
  all_users = Nokogiri::XML(http_get(URL, OPTIONS))
  all_users.search('//user').each do |user|
    admin_user = user.xpath('admin')
    active_user = user.xpath('activated')
    if admin_user.text == 'true' && active_user.text == 'true'
      puts user
    end
  end
end

extract_admin_users

http_get(URL, OPTIONS)