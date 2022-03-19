class Postcode < ApplicationRecord

  has_many :users, inverse_of: :postcodes

  acts_as_mappable lat_column_name: :latitude, 
                   lng_column_name: :longitude

end