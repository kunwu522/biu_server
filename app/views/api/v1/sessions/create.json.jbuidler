json.user do
    json.id         @user.id
    json.username   @user.username
    json.profile do
        json.profile_id @user.profile.id
        json.birthday   @user.profile.birthday
        json.gender     @user.profile.gender
        json.zodia      @user.profile.zodia.id
        json.style      @user.profile.style.id
    end
    json.partner do
        json.partner_id @user.partner.id
        json.sexuality  @user.partner.sexuality.id
        json.min_age    @user.partner.min_age
        json.max_age    @user.partner.max_age
        json.zodiac_ids @user.partner.zodiacs
        json.style_ids  @user.partner.styles
    end
end