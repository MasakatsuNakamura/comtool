# coding: utf-8

class Project < ApplicationRecord
  include ArxmlExporter_r403
  include ArxmlExporter_r422

  has_many :messages
  has_many :modes
  has_many :com_signals
  enum byte_order: %w[big_endian little_endian]
  enum qines_version_id: { v1_0: 1, v2_0: 2 }
  enum communication_protocol_id: { can: 1 }

  # TODO: disabled タスク #654
  attr_accessor :duplicate_source

  accepts_nested_attributes_for :com_signals, reject_if: true
  validates_associated :com_signals

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: '半角英数とアンダースコアが利用できます' }

  def self.qines_version_number
    ''
  end

  def import_dbc(uploadfile)
    MessagesHelper::DbcFileParser.parse(self, uploadfile.read.force_encoding('UTF-8'))
  end

  def export_dbc
    MessagesHelper::DbcFileGenerator.generate(self)
  end

  def to_ecuc_arxml
    if v1_0?
      export_ecuc_comstack_r403(project: self, messages: messages)
    else
      export_ecuc_comstack_r422(project: self, messages: messages)
    end
  end

  def to_systemdesign_arxml
    if v1_0?
      export_signals_r403(project: self, messages: messages)
    else
      export_signals_r422(project: self, messages: messages)
    end
  end
end
