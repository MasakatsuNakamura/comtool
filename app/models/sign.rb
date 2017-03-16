class Sign < ApplicationRecord
  belongs_to :project

  def self.getOwnSigns(project)
    Sign.where(project_id: project)
  end
end
