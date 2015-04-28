json.users @users do |user|
  json.id         user.id
  json.username   user.username
  json.password	  user.password_digest
end