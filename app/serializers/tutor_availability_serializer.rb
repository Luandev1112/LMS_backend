class TutorAvailabilitySerializer < BaseSerializer

  # Fields and inKlude (keyword sidestep) are both from here:
  # https://jsonapi-resources.com/v0.9/guide/serializer.html#Options
  def initialize(records, fields={}, inklude={})
    unless _instance_or_enumerable_of?(records, TutorAvailability)
      raise "Oh come on, just a TutorAvailability or an enumerable collection of them, please"
    end
    super(records, fields, inklude)
  end

  private

  def _default_inklude
    %w(tutor availability)
  end
end