class AddProjectToComSignal < ActiveRecord::Migration[5.0]
  def change
    add_reference :com_signals, :project, foreign_key: true
  end
end
