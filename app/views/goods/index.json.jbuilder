json.array!(@goods) do |good|
  json.extract! good, :id, :name, :main_image_id
  json.url good_url(good, format: :json)
end
