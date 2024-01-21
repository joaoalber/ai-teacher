# THOSE GEMS MUST BE INSTALLED USING THE COMMAND: gem install gem_name

require 'net/http'
require 'net/http/post/multipart'
require 'uri'
require 'json'
require 'oj'

BASE_URL = 'https://api.openai.com/v1'.freeze

START_RECORD_FROM_FILE_NUMBER = 1 # ex: recording0001.mp3
CURRENT_PATH = 'your_current_path' # ex: "C:/Users/spwnd/Desktop/ai-teacher
TOKEN = 'token' # API token

# your voice recordings should be sequential, recording0001, recording0002, et... and they
# must be within the repo path
def file_path
  @file_counter ||= START_RECORD_FROM_FILE_NUMBER
  current_file = "%04d" % @file_counter

  CURRENT_PATH + "/recording#{current_file}.mp3"
end

def post(url, body = nil, multipart: false)
  if multipart
    file = UploadIO.new(file_path, 'audio/mpeg')
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
    messages: messages,
  }.to_json

  Oj.load(post(url, body).body)
end

def messages
  @messages ||= [
    {
      role: "user",
      content: "You are a helpful assistant designed to talk English with me, make questions, act as a persona which is an adult with random characteristics."
    },
  ]

  @messages << { role: "user", content: "#{transcription.body}" }
end

def audio
  url = URI.parse(BASE_URL + '/audio/speech')
  body = { model: "tts-1", input: chat["choices"][0]["message"]["content"], voice: "alloy"  }.to_json

  response = post(url, body)

  File.open('speech.mp3', 'wb') { |file| file.write(response.body) }
end

def execute
  voice_recorded = false

  while !voice_recorded
    begin
      f = File.open(file_path.split('/').last)
      f.close

      transcription
      chat
      audio

      system('start speech.mp3')
      @file_counter = @file_counter + 1
    rescue => e
      sleep 0.2
    end
  end
end

execute
