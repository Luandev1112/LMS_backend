class RegistrationsController < Devise::RegistrationsController

  def create
    user_params_w_postcode = user_params.merge!({ 
      postcode: Postcode.find_by(code: user_params[:postcode])
    })
    build_resource(user_params_w_postcode)
    
    if user_params.key? :profile_image
      resource.profile_image.attach(data: user_params[:profile_image])
    end
    puts resource
    resource.save

    if resource.errors.empty?
      user_class = (user_params[:type] || 'User')
      render json: _serialized!(resource, user_class)

    else
      render json: {
        errors: [{
          status: '400',
          title: 'Bad Request',
          detail: resource.errors,
          code: '100'
        }],
      }, status: :bad_request
    end


  end

  protected


  def _serialized!(record, user_class)
    resource_class = "#{user_class}Resource".constantize

    JSONAPI::ResourceSerializer.new(
      resource_class, 
      { include: ['postcode'] }
    ).serialize_to_hash(
      resource_class.new(record, nil)
    )
  end


  def user_params
    params
      .require(:user)
      .permit(:email, :password, :password_confirmation, :first_name, :last_name, 
              :last_seen, :sex, :age, :biography, :hourly_rate, :postcode,
              :max_distance_available, :profile_image, :type)
  end

end