json.array!(@classifications) do |classification|
  json.extract! classification, :id, :song_name, :artist, :rating, :user_id, :mood, :genre
  json.url classification_url(classification, format: :json)
end
