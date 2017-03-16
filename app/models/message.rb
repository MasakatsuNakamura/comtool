class Message < ApplicationRecord
  belongs_to :project
  attr_accessor :duplicate_source
  has_many :com_signals, dependent: :destroy
  accepts_nested_attributes_for :com_signals, reject_if: true

  def self.getOwnMessages(project)
    Message.where(project_id: project)
  end
end
