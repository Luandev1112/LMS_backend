# From https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance
# That at least is the theory. Bah. I've hacked and bashed and tweaked and massaged
# this all I can - and still, hitting POST /messages/search twice produces the
# same goshdarn STI error message. Search me why. Am I using this snippet wrong?
# Yes? No? Haven't a clue. But I've wasted three days trying to make this damn thing
# work. Enough. I'll cope with this error. Moving on.

module StiPreload
  unless Rails.application.config.eager_load
    extend ActiveSupport::Concern
    #ap "BLARGH"
    included do
      cattr_accessor :preloaded, instance_accessor: false
    end

    class_methods do
      #ap "BLARGH2"
      def descendants
        #ap "BLARGH3"
        
        preload_sti unless preloaded
        super
      end

      # Constantizes all types present in the database. There might be more on
      # disk, but that does not matter in practice as far as the STI API is
      # concerned.
      #
      # Assumes store_full_sti_class is true, the default.
      def preload_sti
        #ap "BLARGH4"
        types_in_db = base_class
          .unscoped
          .select(inheritance_column)
          .distinct
          .pluck(inheritance_column)
          .compact
        #ap types_in_db
        types_in_db.each do |type|
          logger.debug("Preloading STI type #{type}")
          type.constantize
        end

        self.preloaded = true
      end
    end
  end
end