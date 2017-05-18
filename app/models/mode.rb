class Mode < ApplicationRecord
  belongs_to :project

  validates :title,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 }
end
