# THOSE GEMS MUST BE INSTALLED USING THE COMMAND: gem install gem_name

require 'net/http'
require 'net/http/post/multipart'
require 'uri'
require 'json'
require 'oj'

BASE_URL = 'https://api.openai.com/v1'.freeze
FILE_PATH = 'your_file_path' # example => C:/Users/spwnd/Desktop/Recording0010.mp3'
TOKEN = 'token' # your generated OpenAI API token goes here

def post(url, body = nil, multipart: false)
  if multipart
    file = UploadIO.new(FILE_PATH, 'audio/mpeg')
    request = Net::HTTP::Post::Multipart.new(url.path, 'file' => file, 'model' => 'whisper-1', 'response_format' => 'text', 'language' => 'en')
    request['Authorization'] = "Bearer #{TOKEN}"

    Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(request) } 
  else
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{TOKEN}" }

    http.post(url, body, headers)
  end
end

def transcription
  url = URI(BASE_URL + '/audio/transcriptions')

  post(url, multipart: true)
end

def chat
  url = URI.parse(BASE_URL + '/chat/completions')
  body = {
    model: "gpt-3.5-turbo-1106",
    messages: [
      {
        role: "user",
        content: "You are a helpful assistant designed to talk English with me, make questions, act as a normal person."
      },
      {
        role: "user",
        content: "#{transcription.body}"
      }
    ]
  }.to_json

  Oj.load(post(url, body).body)
end

def audio
  url = URI.parse(BASE_URL + '/audio/speech')
  body = { model: "tts-1", input: chat["choices"][0]["message"]["content"], voice: "alloy"  }.to_json

  response = post(url, body)

  File.open('speech.mp3', 'wb') { |file| file.write(response.body) }
end

def execute
  transcription
  chat
  audio
end

execute
