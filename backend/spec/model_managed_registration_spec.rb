require 'spec_helper'

describe 'Runcorn Managed Registration Model' do

  describe "Agency" do
    let!(:agency) do
      AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity))
    end


    it 'comes into life as a draft' do
      expect(agency.registration_state).to eq('draft')
    end


    it 'can be submitted for approval' do
      Registration.submit(agency)

      expect(agency.registration_state).to eq('submitted')
    end


    it 'can be withdrawn from consideration' do
      Registration.submit(agency)
      Registration.withdraw(agency)

      expect(agency.registration_state).to eq('draft')
    end


    it 'can be approved' do
      Registration.submit(agency)
      Registration.approve(agency)

      expect(agency.registration_state).to eq('approved')
    end


    it 'cannot be approved until it has been submitted' do
      Registration.approve(agency)

      expect(agency.registration_state).to eq('draft')
    end


    it 'cannot be edited while submitted' do
      Registration.submit(agency)

      expect{ agency.update_from_json(JSONModel(:agent_corporate_entity).find(agency.id)) }.to raise_error(ReadOnlyException)
    end


    it 'cannot be published while in draft' do
      json = JSONModel(:agent_corporate_entity).find(agency.id)
      json['publish'] = true
      agency.update_from_json(json)
      json = JSONModel(:agent_corporate_entity).find(agency.id)
      expect(json['publish']).to be_falsey
    end


    it 'forces publish and registration_state on create' do
      forced_agency = AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity,
                                                                  {:publish => true, :registration_state => 'approved'}))

      expect(forced_agency.publish).to eq(0)
      expect(forced_agency.registration_state).to eq('draft')
    end


    it 'gets a handy dandy label to indicate an unapproved state' do
      json = JSONModel(:agent_corporate_entity).find(agency.id)
      expect(json['title']).to match(/^\[DRAFT\] /)

      Registration.submit(agency)

      json = JSONModel(:agent_corporate_entity).find(agency.id)
      expect(json['title']).to match(/^\[SUBMITTED\] /)
    end
  end

end
