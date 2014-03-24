json.array!(@images) do |image|
  json.extract! image, :id, :website, :good_id
  json.url image_url(image, format: :json)
end
