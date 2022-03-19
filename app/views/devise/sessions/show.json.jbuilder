if user_signed_in?
  json.user do
    json.(current_user, :id, :email, :first_name, :last_name, :sex, :age, :last_seen, :created_at, :updated_at)
  end
end