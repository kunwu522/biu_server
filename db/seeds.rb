# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if (Zodiac.count == 0)
    Zodiac.create(name: "Aries")
    Zodiac.create(name: "Taurus")
    Zodiac.create(name: "Gemini")
    Zodiac.create(name: "Cancer")
    Zodiac.create(name: "Leo")
    Zodiac.create(name: "Virgo")
    Zodiac.create(name: "Libra")
    Zodiac.create(name: "Scorpio")
    Zodiac.create(name: "Sagittarius")
    Zodiac.create(name: "Capricorn")
    Zodiac.create(name: "Aquarius")
    Zodiac.create(name: "Pisces")
end

if (Style.count == 0)
    Style.create(name: "Rich", gender:1)
    Style.create(name: "GFS", gender:1)
    Style.create(name: "DS", gender:1)
    Style.create(name: "Talent", gender:1)
    Style.create(name: "Soprt", gender:1)
    Style.create(name: "Fashion", gender:1)
    Style.create(name: "BigBoy", gender:1)
    Style.create(name: "Common", gender:1)
    Style.create(name: "All", gender:1)
    Style.create(name: "Godness", gender:0)
    Style.create(name: "BFM", gender:0)
    Style.create(name: "DS", gender:0)
    Style.create(name: "Talent", gender:0)
    Style.create(name: "Soprt", gender:0)
    Style.create(name: "Sexy", gender:0)
    Style.create(name: "LovelyGirl", gender:0)
    Style.create(name: "BusinessWoman", gender:0)
    Style.create(name: "All", gender:0)
end
