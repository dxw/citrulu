class AddIvitationIdAndRemoveInvitationCode < ActiveRecord::Migration
  def up
    add_column :users, :invitation_id, :integer
  end

  def down
    remove_column :users, :invitation_id
  end
end
