json.array!(@parse_requests) do |parse_request|
  json.extract! parse_request, :id, :domain, :count
  json.url parse_request_url(parse_request, format: :json)
end
