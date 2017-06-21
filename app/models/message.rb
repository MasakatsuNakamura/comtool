class Message < ApplicationRecord
  attr_accessor :duplicate_source

  belongs_to :project
  has_many :com_signals, dependent: :destroy
  enum data_frame: %w[standard_can extended_can]

  accepts_nested_attributes_for :com_signals, reject_if: true
  validates_associated :com_signals

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: '半角英数とアンダースコアが利用できます'}

  validates :canid,
            presence: true,
            numericality: true

  validate :message_layout_should_be_correct

  def com_signals_build
    # default com_signal
    unused_name =
      project.com_signals.where("name like 'Signal%'").map do |com_signal|
        if com_signal.name =~ /Signal([0-9]+)/i
          $LAST_MATCH_INFO[1].to_i
        else
          -1
        end
      end.max
    if unused_name.nil?
      unused_name = 1
    else
      unused_name += 1
    end

    # default com_signal
    com_signals.build(
      name: "Signal#{unused_name}",
      unit: 'Enter a unit',
      description: 'Enter a description',
      bit_offset: 0,
      bit_size:   1,
      message: self,
      project: project
      #       sign: Sign.find_by(project_id: self.project_id)
    )
  end

  def self.duplicate_from_arxml(params, opt = {})
    m = Message.new(params)

    # TODO: arxmlからメッセージのプロパティを読み込む
    m.canid = 100
    m.txrx = opt[:duplicate_source] ? opt[:duplicate_source].to_i % 2 : 0
    m.baudrate = 2
    m.bytesize = 1

    if opt[:project]
      m.project = Project.find(opt[:project])
      m.com_signals_build
    end
    m
  end

  private

  def message_layout_should_be_correct
    message_layout = Array.new(bytesize * 8, false)
    com_signals.each do |c|
      offset = c.bit_offset
      bit_size = c.bit_size
      bit_size.times do
        if message_layout[offset].nil?
          errors[:bit_offset] << 'メッセージレイアウトが範囲外です'
          break
        elsif message_layout[offset]
          errors[:bit_offset] << 'メッセージレイアウトが重複しています'
          break
        end
        message_layout[offset] = true
        if project.little_endian?
          offset += 1
        elsif (offset % 8).zero?
          offset += 15
        else
          offset -= 1
        end
      end
    end
  end
end
