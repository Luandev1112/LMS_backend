module Faker

  # Every class in this array has a .character method. Sample one at random and call it.
  # Except Michael Scott, RuPaul, and Community! Search me why.
  def self.any_character
    [
      Faker::Movies.constants
        .map {|m| "Faker::Movies::#{m}".constantize },
      Faker::TvShows.constants
        .reject {|tv| [:MichaelScott, :RuPaul, :Community].include? tv }
        .map {|tv| "Faker::TvShows::#{tv}".constantize },
    ].flatten
     .sample
     .character
  end

end