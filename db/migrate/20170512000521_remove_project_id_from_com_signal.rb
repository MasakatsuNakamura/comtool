class RemoveProjectIdFromComSignal < ActiveRecord::Migration[5.0]
  def change
    remove_column :com_signals, :project_id, :integer
  end
end
