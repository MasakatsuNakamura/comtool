class Message < ApplicationRecord
  belongs_to :project
  attr_accessor :duplicate_source

  def self.getOwnMessages(project)
    Message.where(project_id: project)
  end
end
