class GrantScopesToExistingIdentities < ActiveRecord::Migration
  def up
    client = Client.find_by_identifier("WACKADOOHTML5")
    
    return if client.blank?
    
    Identity.all.each do |identity|
      identity.grants.create({
        client_id: client.id,
        scopes:    client.scopes,
      });
    end
  end

  def down
  end
end
