json.users @users do |user|
  json.id         user.id
  json.username   user.username
  json.email	  user.email
  json.password	  user.password_digest
end