## Paperclip settings
## This avoids file system limitations due to maximum number of items in a directory.
## Trust me, I've learned this one from experience - Hans
#
#Paperclip::Attachment.default_options[:url] = "/system/:class/:attachment/:id_partition/:style/:basename.:extension"
#Paperclip::Attachment.default_options[:path] = ":rails_root/public/system/:class/:attachment/:id_partition/:style/:basename.:extension"
#

Paperclip::Attachment.default_options.update({
    :url => "/storage/:class/:attachment/:id_partition/:style/:basename.:extension",
    :path => ":rails_root/public/storage/:class/:attachment/:id_partition/:style/:basename.:extension"
})

# On windows machines with excel installed, browsers tend to upload csv files with content type "application/vnd.ms-excel"
# but paperclip's built-in filetype detection thinks that it should be text/plain and rejects the file.  This setting is to 
# tell paperclip to stop complaining about that.  
Paperclip.options[:content_type_mappings] = {
  csv: [ "application/vnd.ms-excel", "text/plain" ],
}
