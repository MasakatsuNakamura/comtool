class Message < ApplicationRecord
  belongs_to :project
  attr_accessor :duplicate_source
  has_many :com_signals, dependent: :destroy
  accepts_nested_attributes_for :com_signals, reject_if: true

  def self.getOwnMessages(project)
    Message.where(project_id: project)
  end

  def Message.duplicate_from_arxml(params, duplicate_source)
    m = Message.new(params)

    # TODO arxmlからメッセージのプロパティを読み込む
    m.canid = 100
    m.txrx  = duplicate_source.to_i % 2
    m.baudrate = 2
    m.bytesize  = 1

    m
  end
end
