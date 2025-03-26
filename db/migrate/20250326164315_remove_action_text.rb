class RemoveActionText < ActiveRecord::Migration[8.0]
  def change
    drop_table :action_text_rich_texts if table_exists?(:action_text_rich_texts)

    # ลบ migration เก่าออก
    execute "DELETE FROM schema_migrations WHERE version = '20250326144009'"
  end
end
