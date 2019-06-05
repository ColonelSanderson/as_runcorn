require 'spec_helper'

describe 'Runcorn Movements Mixin' do

  it "keeps track of physical representation movements" do
    json = build(:json_archival_object)

    json.physical_representations =
      [
       {
         "title" => "bad song",
         "description" => "Let us get physical!",
         "current_location" => "N/A",
         "normal_location" => "N/A",
         "format" => "Drafting Cloth (Linen)",
         "contained_within" => "OTH",
         "movements" =>
         [
          {
            "functional_location" => "CONS",
            "user" => "admin",
            "move_context" => { "ref" => "/file_issue/1"},
            "move_date" => "2019-06-06"
          }
         ]
       }
      ]

    obj = ArchivalObject.create_from_json(json)
    json = ArchivalObject.to_jsonmodel(obj.id)

    prep = json.physical_representations[0]

    expect(prep['movements'].length).to eq(1)
    expect(prep['movements'][0]['functional_location']).to eq('CONS')
  end


  it "keeps track of top container movements" do
    json = build(:json_top_container)

    json.movements = 
      [
       {
         "functional_location" => "CONS",
         "user" => "admin",
         "move_date" => "2019-06-06"
       }
      ]

    obj = TopContainer.create_from_json(json)
    json = TopContainer.to_jsonmodel(obj.id)

    expect(json['movements'].length).to eq(1)
    expect(json['movements'][0]['functional_location']).to eq('CONS')
  end

  it "supports moves to storage locations" do
    location = create(:json_location)

    json = build(:json_top_container)

    json.movements = 
      [
       {
         "storage_location" => {"ref" => location.uri},
         "user" => "admin",
         "move_date" => "2019-06-06"
       }
      ]

    obj = TopContainer.create_from_json(json)
    json = TopContainer.to_jsonmodel(obj.id)

    expect(json['movements'].length).to eq(1)
    expect(json['movements'][0]['storage_location']["ref"]).to eq(location.uri)
  end

  it "insists exactly one of function or storage location is specified" do
    location = create(:json_location)

    json = build(:json_top_container)

    json.movements = 
      [
       {
         "storage_location" => {"ref" => location.uri},
         "functional_location" => "CONS",
         "user" => "admin",
         "move_date" => "2019-06-06"
       }
      ]

    expect {TopContainer.create_from_json(json)}.to raise_error(JSONModel::ValidationException)

    json.movements = 
      [
       {
         "user" => "admin",
         "move_date" => "2019-06-06"
       }
      ]

    expect {TopContainer.create_from_json(json)}.to raise_error(JSONModel::ValidationException)
  end
end