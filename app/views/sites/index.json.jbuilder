json.array!(@sites) do |site|
  json.extract! site, :id, :domain, :name_selector, :main_image_selector, :images_selector, :button_selector
  json.url site_url(site, format: :json)
end
