json.results do
  json.base do
    json.array! @record.errors.messages[:base] if @record
  end
  json.warning do
    json.array! @record.errors.messages[:warning] if @record
  end
end
