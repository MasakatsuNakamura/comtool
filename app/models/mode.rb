class Mode < ApplicationRecord
  belongs_to :project

  after_initialize :set_default, if: :new_record?

  validates :title,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 }

  private

  def set_default
    self.param = "条件1:\r\n    condition: AAA == BBB\r\n    true: アクション1\r\n    false: アクション2\r\n"
  end
end
