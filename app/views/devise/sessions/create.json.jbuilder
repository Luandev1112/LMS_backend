if user_signed_in?
  json.user do
    json.(current_user, :id, :email)
    json.token @token
  end
end