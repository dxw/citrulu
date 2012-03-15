class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :code
      t.string :description
      t.boolean :enabled

      t.timestamps
    end
  end
end
