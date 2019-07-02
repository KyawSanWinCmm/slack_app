class CreateTGroupMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :t_group_messages do |t|
      t.string :groupmsg
      t.integer :channelid
      t.references :m_channel, foreign_key: true
      t.references :m_user, foreign_key: true

      t.timestamps
    end
    add_index :t_group_messages, [:m_channel_id, :created_at]
    add_index :t_group_messages, [:m_user_id, :created_at]
  end
end
