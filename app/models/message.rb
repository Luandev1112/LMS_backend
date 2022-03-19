class Message < ApplicationRecord

  belongs_to :messager,
    class_name: 'User',
    inverse_of: :sent_messages
  belongs_to :messagee,
    class_name: 'User',
    inverse_of: :received_messages

  validates :content, presence: true

  # Message search!
  # Params validation is handled on the messages controller.
  # messager_id: current_user.id. 
  # messagee_id (recipient user ID) 
  # before/after bounds
  # seen: boolean
  # page_number: default 0.
  # page_size: default 20.
  # Ordering? TBD.
  # 
  scope :search, -> (params) {

    params[:page_number] = 0 unless params.key? :page_number
    params[:page_size] = 20 unless params.key? :page_size

    q = where(messager_id: params[:messager_id])
    q = q.where(messagee_id: params[:messagee_id]) if params.key? :messagee_id
    q = q.where('created_at > ?', params[:after]) if params.key? :after
    q = q.where('created_at < ?', params[:before]) if params.key? :before 
    q = q.where("seen_at IS #{params[:seen] ? 'NOT' : ''} NULL") if params.key? :seen
    q = q.limit(params[:page_size])
      .offset(params[:page_number] * params[:page_size])
      .order('updated_at desc')
  }

end