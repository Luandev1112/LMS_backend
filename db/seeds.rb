require 'csv'

if Rails.env.production?
  puts "Are you nuts? We're in Prod! `rake db:seed` will wipe the entire database! You're a numpty. Exiting now."
  exit
end

[
  LanguageUser,
  SubjectTutor,
  TutorAvailability,
  Availability,
  Language,
  Subject,
  User,
  Postcode,
].each(&:destroy_all)

# Create a bunch of Languages
%w(English Dutch German French).each do |language|
  l = Language.create name: language
  ap "Created language with id=#{ l.id } name=#{ l.name }"
end

# Create a bunch of Subjects
%w(English Mathematics Physics Chemistry Biology).each do |subject|
  s = Subject.create name: subject
  ap "Created subject with id=#{ s.id } name=#{ s.name }"
end

# Create a bunch of Availabilities
['Morning', 'Minus-infinity-o-clock', 'Too damn early', 'Too damn late', 'Teatime', 'Brunch', 'Morning tea', 'Nightcap', 'Midnight feast'].each do |name|
  a = Availability.create name: name
  ap "Created availability with id=#{ a.id } name=#{ a.name }"
end

# Create a shitload of Postcodes
# What's :encoding? Behold: stackoverflow.com/questions/8380113
codes = []
CSV.read(Rails.root.join('db', 'nl_postal_codes.csv'), headers: true, encoding: 'iso-8859-1:utf-8').each do |row|
  codes << { code: row[0], name: row[1], state: row[2], county: row[3], latitude: row[4], longitude: row[5] }
end
Postcode.create(codes)

lowest_postcode_id = Postcode.select(:id).order('id asc').limit(1)[0].id

# Create a bunch of Students
2.upto(6) do |i|
  s_attrs = {
    email: "#{i}@s.com", 
    first_name: "sf_#{i}",
    last_name: "sl_#{i}",
    password: '12345678', 
    password_confirmation: '12345678', 
    postcode: Postcode.find_by_id(lowest_postcode_id+i*100)
  }

  s = Student.create(s_attrs)
  if s.valid?
    ap "Created student with id=#{ s.id }"
  else
    ap s.errors.messages
  end
end

# Create a bunch of Tutors
2.upto(25) do |i|
  t_attrs = {
    email: "#{i}@t.com", 
    first_name: "tf_#{i}", 
    last_name: "tl_#{i}",
    password: '12345678', 
    password_confirmation: '12345678', 
    postcode: Postcode.find_by_id(lowest_postcode_id+i*100)
  }

  t = Tutor.create(t_attrs)
  ap "Created tutor with id=#{ t.id }"
end

# Assign two random Languages to each User, of both types
User.all.each do |user|
  Language.order("RANDOM()").limit(2).each do |language|
    LanguageUser.create language: language, user: user
    ap "Created LanguageUser with language=#{ language.name }, user=#{ user.first_name } #{ user.last_name }"
  end
end

# Assign two random Subjects and Availabilities to each Tutor
Tutor.all.each do |tutor|
  Subject.order("RANDOM()").limit(2).each do |subject|
    SubjectTutor.create subject: subject, tutor: tutor
    ap "Created SubjectTutor with subject=#{ subject.name }, tutor=#{ tutor.first_name } #{ tutor.last_name }"
  end

  Availability.order("RANDOM()").limit(2).each do |availability|
    TutorAvailability.create tutor: tutor, availability: availability
    ap "Created TutorAvailability with availability=#{ availability.name }, tutor=#{ tutor.first_name } #{ tutor.last_name }"
  end
end
