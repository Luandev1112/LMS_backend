class Tutor < User

  # def set_type
  #   self.type = 'Tutor'
  # end

  has_many :saved_profiles,
    inverse_of: :savee
  has_many :saved_students, # The list
    through: :saved_profile, 
    inverse_of: :saved_tutors 
  has_many :subject_tutors, 
    inverse_of: :tutor
  has_many :subjects, 
    through: :subject_tutors, 
    inverse_of: :tutors
  has_many :reviews,
    inverse_of: :reviewee, 
    foreign_key: :reviewee_id
  has_many :tutor_availabilities, 
    inverse_of: :tutor
  has_many :availabilities, 
    through: :tutor_availabilities, 
    inverse_of: :tutors

  accepts_nested_attributes_for :subject_tutors, :tutor_availabilities

  # Search our beloved tutors.
  # Availabilities: optional. Array of availability IDs. 
  # Postcode: optional. If present, order the tutor results by geographical distance between
  #   them and the postcode.
  # distance: optional. If present, filter out all tutors with distance greater.
  # Hourly rate: optional. Either low- or high-bounds. Filter out tutors outside them.
  # Subjects. Optional. An array of IDs.
  # Languages. Optional. An array of IDs.
  # Page number: Optional. If absent, defaults to 0. Can be any positive integer.
  # Page size: Optional. If absent, defaults to 20. Can be any positive integer.

  scope :search, -> (params) {
    params[:page_number] = 0 unless params.key? :page_number
    params[:page_size] = 20 unless params.key? :page_size

    # '.unscoped': its absence causes deprecation errors. See https://github.com/stefankroes/ancestry/pull/442
    query = unscoped.includes :postcode, :subjects, :languages, :availabilities

    query = query.joins(:availabilities).where('availabilities.id IN (?)', params[:availabilities]) if params.key? :availabilities
    query = query.joins(:subjects).where('subjects.id IN (?)', params[:subjects]) if params.key? :subjects
    query = query.joins(:languages).where('languages.id IN (?)', params[:languages]) if params.key? :languages

    if params.key? :rate
      query = query.where('users.hourly_rate > ?', params[:rate][:low]) if params[:rate].key? :low 
      query = query.where('users.hourly_rate < ?', params[:rate][:high]) if params[:rate].key? :high
    end

    # If :postcode is present, order by distance from it, otherwise by updated_at.
    if params.key? :postcode
      if p = Postcode.find_by_code(params[:postcode])
        query = query.within(params[:distance], origin: [p.latitude, p.longitude]) if params.key? :distance
        query = query.joins(:postcode).by_distance(origin: [p.latitude, p.longitude])
      end
    end

    query.limit(params[:page_size])
      .offset(params[:page_number] * params[:page_size])
      .order('users.updated_at desc')
  }
end