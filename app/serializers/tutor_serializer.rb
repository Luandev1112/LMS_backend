class TutorSerializer < BaseSerializer

  def initialize(records, fields={}, inklude={})
    unless _instance_or_enumerable_of?(records, Tutor)
      raise "Oh come on, just a Tutor or an enumerable collection of them, please"
    end
    super(records, fields, inklude)
  end

  private

  def _default_inklude
    ['tutor_availabilities', 
     'tutor_availabilities.availabilities',
     'subject_tutors',
     'subject_tutors.subjects']
  end
end
