builder.ABOUT_VERSIONS do
  builder.ABOUT_VERSION do
    builder.AboutVersionIdentifier version
    builder.CreatedDatetime Time.now.utc.xmlschema.gsub('Z', '')
  end
end
