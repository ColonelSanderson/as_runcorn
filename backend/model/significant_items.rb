class SignificantItems

  def self.list(level = false)
    if level && level != 'all'
      query.filter(:significance__value => level).all.map{|row| format(row)}
    else
      query.filter(Sequel.~(:significance__value => 'standard')).all.map{|row| format(row)}
    end
  end


  def self.format(row)
    {
      :significance => row[:prep_significance],
      :qsa_id => QSAId.prefixed_id_for(PhysicalRepresentation, row[:prep_qsa_id]),
      :label => row[:prep_label],
      :functional_location => row[:prep_fn_loc],
      :uri => JSONModel::JSONModel(:physical_representation).uri_for(row[:prep_id], :repo_id => row[:repo_id]),
      :container => {
        :label => row[:tcon_indicator],
        :functional_location => row[:tcon_fn_loc],
        :uri => JSONModel::JSONModel(:top_container).uri_for(row[:tcon_id], :repo_id => row[:repo_id]),
        :storage_location => {
          :label => row[:loc_label],
          :uri => JSONModel::JSONModel(:location).uri_for(row[:loc_id], :repo_id => row[:repo_id]),
        }
      },
      :record => {
        :qsa_id => QSAId.prefixed_id_for(ArchivalObject, row[:record_qsa_id]),
        :label => row[:record_label],
        :uri => JSONModel::JSONModel(:archival_object).uri_for(row[:record_id], :repo_id => row[:repo_id]),
      },
      :series => {
        :qsa_id => QSAId.prefixed_id_for(Resource, row[:series_qsa_id]),
        :label => row[:series_label],
        :uri => JSONModel::JSONModel(:resource).uri_for(row[:series_id], :repo_id => row[:repo_id]),
      }
    }
  end


  def self.query
    DB.open do |db|
      db[:physical_representation]
        .left_join(Sequel.as(:enumeration_value, :significance), :significance__id => :physical_representation__significance_id)
        .left_join(Sequel.as(:enumeration_value, :prep_fn_loc), :prep_fn_loc__id => :physical_representation__current_location_id)
        .left_join(:representation_container_rlshp, :representation_container_rlshp__physical_representation_id => :physical_representation__id)
        .left_join(:top_container, :top_container__id => :representation_container_rlshp__top_container_id)
        .left_join(:top_container_housed_at_rlshp, :top_container_housed_at_rlshp__top_container_id => :top_container__id)
        .left_join(Sequel.as(:enumeration_value, :tcon_fn_loc), :tcon_fn_loc__id => :top_container__current_location_id)
        .left_join(:location, :location__id => :top_container_housed_at_rlshp__location_id)
        .left_join(:archival_object, :archival_object__id => :physical_representation__archival_object_id)
        .left_join(:resource, :resource__id => :archival_object__root_record_id)
        .reverse(:significance__position)
        .select(
                Sequel.as(:physical_representation__repo_id, :repo_id),
                Sequel.as(:physical_representation__id, :prep_id),
                Sequel.as(:physical_representation__qsa_id, :prep_qsa_id),
                Sequel.as(:physical_representation__title, :prep_label),
                Sequel.as(:significance__value, :prep_significance),
                Sequel.as(:prep_fn_loc__value, :prep_fn_loc),
                Sequel.as(:top_container__id, :tcon_id),
                Sequel.as(:top_container__indicator, :tcon_indicator),
                Sequel.as(:tcon_fn_loc__value, :tcon_fn_loc),
                Sequel.as(:location__id, :loc_id),
                Sequel.as(:location__title, :loc_label),
                Sequel.as(:archival_object__id, :record_id),
                Sequel.as(:archival_object__qsa_id, :record_qsa_id),
                Sequel.as(:archival_object__display_string, :record_label),
                Sequel.as(:resource__id, :series_id),
                Sequel.as(:resource__qsa_id, :series_qsa_id),
                Sequel.as(:resource__title, :series_label)
                )
    end
  end
end