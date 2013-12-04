get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/address/:key' do
  headers('Content-Type' => "image/jpeg")
  open_image(params[:key])
end

def open_image(key)
  if exists?(key)
    open(to_public_url(key))
  else
    open(create_and_upload(key))
  end
end
