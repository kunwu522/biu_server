json.user do
  json.id 		@user.id
  json.username @user.username
  json.password @user.password_digest
end