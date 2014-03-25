json.array!(@site_errors) do |site_error|
  json.extract! site_error, :id, :domain
  json.url site_error_url(site_error, format: :json)
end
