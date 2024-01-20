# THOSE GEMS MUST BE INSTALLED USING THE COMMAND: gem install gem_name

require 'net/http'
require 'net/http/post/multipart'
require 'uri'
require 'json'
require 'oj'

url = URI('https://api.openai.com/v1/audio/transcriptions')
token = 'token'

file_path = 'C:/Users/spwnd/Desktop/Recording0009.mp3'
file = UploadIO.new(file_path, 'audio/mpeg')

request = Net::HTTP::Post::Multipart.new url.path,
  'file' => file,
  'model' => 'whisper-1',
  'response_format' => 'text',
  'language' => 'en'

request['Authorization'] = "Bearer #{token}"

response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
  http.request(request)
end

url = URI.parse('https://api.openai.com/v1/chat/completions')

body = {
  model: "gpt-3.5-turbo-1106",
  messages: [
    {
      role: "user",
      content: "You are a helpful assistant designed to talk English with me, make questions, act as a normal person."
    },
    {
      role: "user",
      content: "#{response.body}"
    }
  ]
}.to_json

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
headers = {
  'Content-Type' => 'application/json',
  'Authorization' => "Bearer #{token}"
}

response = http.post(url, body, headers)

response = Oj.load(response.body)

url = URI.parse('https://api.openai.com/v1/audio/speech')

# Create the request body
body = {
  model: "tts-1",
  input: response["choices"][0]["message"]["content"],
  voice: "alloy"
}.to_json

# Configure the HTTP request
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
headers = {
  'Content-Type' => 'application/json',
  'Authorization' => "Bearer #{token}"
}

# Perform the POST request
response = http.post(url, body, headers)

# Save the response body to a file
File.open('speech.mp3', 'wb') do |file|
  file.write(response.body)
end
