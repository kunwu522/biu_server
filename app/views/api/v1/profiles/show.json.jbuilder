json.profile do
  json.id 		    @profile.id
  json.username     @profile.user.username
  json.gender       @profile.gender
  json.birthday     @profile.birthday
  json.zodiac_id    @profile.zodiac.id
  json.style_id     @profile.style.id
end