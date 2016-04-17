desc "Replace user_id with uuid"
task :migrate_user_id_in_validations => :environment do
  UwRegistrationValidation.where("created_at < '2013-03-07 07:00'").each do |u|
    p 'URV--------------------------------------------'
    p u.user_id
    update_from_old_user u unless u.user_id.class.eql?(String)
    p u.user_id
  end

  UwValidationAlert.where("created_at < '2013-03-07 07:00'").each do |u|
    p 'UVA--------------------------------------------'
    p u.user_id
    update_from_old_user u unless u.user_id.class.eql?(String)
    p u.user_id
  end

  UwRegistrationValidation.where("created_at > '2013-03-07 06:59'").each do |u|
    p 'URV--------------------------------------------'
    p u.user_id
    update_from_new_user u unless u.user_id.class.eql?(String)
    p u.user_id
  end

  UwValidationAlert.where("created_at > '2013-03-07 06:59'").each do |u|
    p 'UVA--------------------------------------------'
    p u.user_id
    update_from_new_user u unless u.user_id.class.eql?(String)
    p u.user_id
  end
end

def update_from_old_user u
  user = UserOld.where(id: u.user_id.gsub(' NOT FOUND', '')).first
  if user
    new_user = User.find(user.login)
    u.user_id = new_user.uuid if new_user
  else
    u.user_id = "#{u.user_id.gsub(' NOT FOUND', '')} NOT FOUND"
  end
  u.save!
end


def update_from_new_user u
  user = User.find(u.user_id.gsub(' NOT FOUND', ''))
  if user
    u.user_id = user.uuid if user
  else
    u.user_id = "#{u.user_id.gsub(' NOT FOUND', '')} NOT FOUND"
  end
  u.save!
end