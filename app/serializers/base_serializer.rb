# This class and its descendants are basically just wrappers for jsonapi-resources
# serializers. They house common methods, common early-return guards, common
# defaults, other shenanigans.

class BaseSerializer

  attr_accessor :records, :fields, :inklude

  def initialize(records, fields={}, inklude={})
    # records is either a model or a collection. Collection? Make a proper array.
    @records = records.respond_to?(:each) ? records.to_a : records
    @fields = fields
    # Each model requires specific defaults. Use those normally.
    @inklude = inklude == {} ? _default_inklude : inklude
  end

  def serialize
    return { data: [] } if @records.blank?

    JSONAPI::ResourceSerializer.new(
      _resource_class,
      _serializer_options
    ).serialize_to_hash(_resources)
  end

  private

  def _resources
    if @records.is_a? Array
      @records.map{ |r| _resource_class.new(r, nil) }
    else
      _resource_class.new(@records, nil)
    end
  end

  def _resource_class
    "#{_model_class}Resource".constantize
  end

  def _model_class
    if @records.is_a? Array
      @records[0]
    else
      @records
    end.class
  end

  def _serializer_options
    options = { include: @inklude }
    options[:fields] = @fields if @fields != {}
    options
  end

  def _instance_or_enumerable_of?(candidate, klass)
    candidate.is_a?(klass) || (candidate.respond_to?(:all?) && candidate.all?{|c| c.is_a?(klass) })
  end
end