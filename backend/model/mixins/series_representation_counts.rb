module SeriesRepresentationCounts

  extend JSONModel

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def sequel_to_jsonmodel(objs, opts = {})
      jsons = super

      representations_counts = prepare_counts(objs)

      objs.zip(jsons).each do |obj, json|
        json['physical_representations_count'] = representations_counts.fetch(obj.id, {}).fetch('physical_representations_count', 0)
        json['digital_representations_count'] = representations_counts.fetch(obj.id, {}).fetch('digital_representations_count', 0)
      end

      jsons
    end

    def prepare_counts(objs)
      result = {}

      node_type_backlink_col = :"#{self.node_model.table_name}_id"

      root_ids = objs.map(&:id)
      node_ids = self.node_model.filter(:root_record_id => root_ids).select(:id)

      node_physical_representation_counts = {}
      node_digital_representation_counts = {}

      PhysicalRepresentation
        .inner_join(self.node_model.table_name, Sequel.qualify(PhysicalRepresentation.table_name, node_type_backlink_col) => Sequel.qualify(self.node_model.table_name, :id))
        .filter(node_type_backlink_col => node_ids)
        .group_and_count(Sequel.qualify(self.node_model.table_name, :root_record_id)).each do |row|
        node_physical_representation_counts[row[:root_record_id]] = row[:count]
      end

      DigitalRepresentation
        .inner_join(self.node_model.table_name, Sequel.qualify(DigitalRepresentation.table_name, node_type_backlink_col) => Sequel.qualify(self.node_model.table_name, :id))
        .filter(node_type_backlink_col => node_ids)
        .group_and_count(Sequel.qualify(self.node_model.table_name, :root_record_id)).each do |row|
        node_digital_representation_counts[row[:root_record_id]] = row[:count]
      end

      objs.each do |obj|
        result[obj.id] = {
          'physical_representations_count' => node_physical_representation_counts.fetch(obj.id, 0),
          'digital_representations_count' => node_digital_representation_counts.fetch(obj.id, 0),
        }
      end

      result
    end
  end
end