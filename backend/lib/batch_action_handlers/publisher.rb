class Publisher < BatchActionHandler

  register(:publisher,
           'Publish or unpublish items and representations. Objects already in the target state will not be updated',
           [:archival_object, :physical_representation, :digital_representation],
           :manage_repository)


  def self.default_params
    {
      'publish' => true
    }
  end


  def self.validate_params(params)
  end


  def self.perform_action(params, user, action_uri, uris)
    validate_params(params)

    counts = {}
    already = {}
    unpublishable = {}

    publish = params['publish'] ? 1 : 0
    now = Time.now

    DB.open do |db|
      uris.map {|uri| {:uri => uri, :parsed => JSONModel.parse_reference(uri)}}
          .group_by {|parsed| parsed[:parsed].fetch(:type)}
          .each do |type, type_refs|

        # spending a little time in json land to avoid messing up the RAP logic
        model = ASModel.all_models.select{|m| m.table_name == type.intern}.first
        jsons = model.sequel_to_jsonmodel(model.filter(:id => type_refs.map {|ref| ref[:parsed].fetch(:id)})
                                               .filter(Sequel.~(:publish => publish)).all)

        all_count = jsons.length

        if type_refs.length > all_count
          already[type] = type_refs.length - all_count
        end

        if publish == 1
          # if we're trying to publish, only publish the publishable!
          jsons = jsons.select{|json| json['publishable']}
          if all_count > jsons.length
            unpublishable[type] = all_count - jsons.length
          end
        end

        counts[type] = db[type.intern].filter(:id => jsons.map {|json| JSONModel.parse_reference(json[:uri]).fetch(:id)})
                                      .update(:publish => publish,
                                              :lock_version => Sequel.expr(1) + :lock_version,
                                              :system_mtime => now,
                                              :user_mtime => now,
                                              :last_modified_by => user)
      end
    end

    state = "#{publish == 1 ? '' : 'un'}published"

    out = "Number of objects #{state}:\n    "
    out += counts.map{|model, count| "    #{I18n.t(model + '._singular')}: #{count}" }.join("\n")

    unless unpublishable.empty?
      out += "\n\nNumber of objects not published due to RAP restrictions:\n    "
      out += unpublishable.map{|model, count| "    #{I18n.t(model + '._singular')}: #{count}" }.join("\n")
    end

    unless already.empty?
      out += "\n\nNumber of objects not updated because they are already #{state}:\n    "
      out += already.map{|model, count| "    #{I18n.t(model + '._singular')}: #{count}" }.join("\n")
    end

    out
  end
end