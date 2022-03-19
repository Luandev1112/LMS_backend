class TutorResource < UserResource

  attributes :max_distance_available, :hourly_rate, :biography

  # has_many :saved_profiles, 
  #   foreign_key: :savee_id,
  #   always_include_linkage_data: true
  has_many :saved_student,
    exclude_links: :default

  has_many :subject_tutors, 
    always_include_linkage_data: true,
    exclude_links: :default
  has_many :reviews, 
    foreign_key: :reviewee_id,
    exclude_links: :default
  has_many :tutor_availabilities, 
    always_include_linkage_data: true,
    exclude_links: :default
  

  # Comment out the filters for now. We're only adding our resources to aid in
  # serialization. For now. 
  
  # TutorResource also inherits a :languages filter from UserResource

  # # 'availabilities' is a comma-separated list of availability IDs.
  # # Remember: Tutors have-and-belong-to-many Availabilities.
  # filter :availabilities,
  #   verify: -> (values, _context) { values.map(&:to_i) },
  #   apply: -> (records, ids, _options) {
  #     return records if ids.length == 0
 
  #     records = records.includes(tutor_availabilities: :availabilities)
  #                      .joins(tutor_availabilities: :availabilities)
  #                      .where('availabilities.id IN (?)', ids)
  #   }


  # # 'subjects' is a comma-separated list of subject IDs.
  # # Remember: Tutors have-and-belong-to-many Subjects.
  # filter :subjects,
  #   verify: -> (values, _context) { values.map(&:to_i) },
  #   apply: -> (records, ids, _options) {
  #     return records if ids.length == 0

  #     records = records.includes(subject_tutors: :subjects)
  #                      .joins(subject_tutors: :subjects)
  #                      .where('subjects.id IN (?)', ids)
  #   }


  # # 'hourly_rate' is a hash: { low: x, high: y }. 
  # # TutorsController#validate_params! ensures this.
  # filter :hourly_rate,
  #   apply: -> (records, values, options) {

  #     records
  #   }
end