class MessagesController < ApplicationController

  before_action :authenticate_user!
  before_action :validate_search_params!, only: :search
  load_resource only: [:update, :destroy]
  authorize_resource

  # POST /messages. Search all messages owned by the current user.
  def search
    messages = Message.search search_params.merge!(messager_id: current_user.id)

    render json: MessageSerializer.new(messages).serialize
  end

  # POST /messages. Create a new message: author (messager): current user;
  # recipient (messagee): to be supplied.
  def create
    message = Message.new(message_params)
    message.messager = current_user

    if message.valid?
      message.save!
      render json: MessageSerializer.new(message).serialize
    else
      render json: { errors: message.errors.messages }, status: 422
    end
  end

  def update
    @message.update! message_params

    if @message.valid?
      render json: MessageSerializer.new(@message).serialize
    else
      render json: { errors: @message.errors.messages }, status: 422
    end
  end

  def destroy
    @message.destroy

    render json: MessageSerializer.new(@message).serialize
  end

  private

  def message_params
    params.require(:message).permit(:messagee_id, :content, :seen_at)
  end

  def search_params
    params.permit!.to_h
  end

  def validate_search_params!
    message_search_api_schema = {
      type: 'object',
      required: [],
      properties: {
        messagee_id: {
          type: 'integer',
          minimum: 1,
        },
        before: {
          type: 'string',
          format: 'date-time',
        },
        after: {
          type: 'sting',
          format: 'date-time',
        },
        seen: { type: 'boolean' },
        page_number: {
          type: 'integer',
          minimum: 0,
        },
        page_size: {
          type: 'integer',
          minimum: 0,
        },
      },
    }

    errors = JSON::Validator.fully_validate(message_search_api_schema, search_params)
    
    # SPECIAL CASE: :before can't be after :after, can it.
    if errors.length == 0
      if search_params.key?(:before) && search_params.key?(:after)
        if DateTime.parse(search_params[:before]) > DateTime.parse(search_params[:after])
          errors << "The property '#/before' can't be more recent than '#/after, now can it, sweetie-darling"
        end
      end
    end

    if errors.length > 0
      render json: {
        status: "A cheapass like you can't afford me, can you, #{ Faker.any_character }, not with JSON that invalid",
        error: errors 
      }.to_json, status: 402
    end
  end
end