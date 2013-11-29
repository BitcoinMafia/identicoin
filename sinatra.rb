get '/:key' do
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
