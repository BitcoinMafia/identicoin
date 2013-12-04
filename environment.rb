require 'open-uri'
require 'set'
require 'bundler/setup'
require 'sinatra'

configure :production do
  require 'newrelic_rpm'
end

Bundler.require

def create_and_upload(key)
  local_path = to_local_dir(key)
  RubyIdenticon.create_and_save(key, local_path, square_size: 15, border_size: 5)
  Thread.new { upload_file(key, local_path) }
  return local_path
end

def to_local_dir(key)
  "tmp/#{key}.jpeg"
end

def s3_directory
  connection = Fog::Storage.new({
    :provider                 => 'AWS',
    :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY']
    })

  connection.directories.get(ENV['AWS_BUCKET'])
end

def all_keys
  s3_directory.files.map { |file| file.key }.to_set
end

def upload_file(key, filepath)
  puts "\nUploading the file to s3..."

  file = s3_directory.files.create(
    :key    => to_s3_key(key),
    :body   => File.open(filepath),
    :public => true
    )

  FileUtils.rm filepath
  if file.save
    update_keys
    puts "Uploading succesful."
    link = file.public_url
    puts "\nYou can view the file here on s3:", link
    return link
  else
    puts "Error placing the file in s3."
    puts "-"*60
    return false
  end
end

def to_s3_key(key)
  "img/#{key}"
end

def to_public_url(key)
  "https://identicoin.s3.amazonaws.com/img/#{key}"
end

def exists?(key)
  settings.existing_keys.include?(to_s3_key(key))
end

def update_keys
  settings.existing_keys = all_keys
end


set :server, :puma
set :existing_keys, all_keys
set :public_folder, File.dirname(__FILE__) + '/public'

load "./sinatra.rb"
