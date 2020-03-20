require 'db/migrations/utils'

Sequel.migration do
  up do
    self.transaction do
      old_enum_id = self[:enumeration_value][:value => 'Digital Media - Other'][:id]
      new_enum_id = self[:enumeration_value][:value => 'Digital Media - Other'][:id]

      self[:digital_representation].filter(:contained_within_id => old_enum_id).update(:contained_within_id => new_enum_id)
      self[:enumeration_value].filter(:id => old_enum_id).delete
    end
  end
end

