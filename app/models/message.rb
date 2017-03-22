class Message < ApplicationRecord
  belongs_to :project
  attr_accessor :duplicate_source
  has_many :com_signals, dependent: :destroy
  accepts_nested_attributes_for :com_signals, reject_if: true

  validates :name,
            presence: true,
            length: { maximum: 50 }

  def self.getOwnMessages(project)
    Message.where(project_id: project)
  end

  def com_signals_build
    # default com_signal
    c = self.com_signals.build(
        name: 'Enter a name',
        unit: 'Enter a unit',
        description: 'Enter a description',
        bit_offset: 0,
        bit_size:   self.bytesize*8,
        message: self,
        sign: Sign.find_by(project_id: self.project_id)
      )
  end

  def Message.duplicate_from_arxml(params, opt = {})
    m = Message.new(params)

    # TODO arxmlからメッセージのプロパティを読み込む
    if (opt[:duplicate_source]) then
      m.canid = 100
      m.txrx  = opt[:duplicate_source].to_i % 2
      m.baudrate = 2
      m.bytesize  = 1
    else
      m.canid = 100
      m.txrx  = 0
      m.baudrate = 2
      m.bytesize  = 1
    end

    if (opt[:project]) then
      prj = opt[:project]

      m.project = Project.find_by_id(prj)
      c = m.com_signals_build
    end

    m
  end
end
