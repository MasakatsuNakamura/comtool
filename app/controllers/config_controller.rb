class ConfigController < ApplicationController
  include ArxmlExporter

  def export_ecuc
    project = Project.find_by_id(session[:project])
    messages = Message.getOwnMessages(session[:project])
    version = QinesVersion.find_by_id(project[:qines_version_id]).qines_version_number

    if version == "1" then
      arxml = export_ecuc_comstack_r403(project:project, messages:messages)
    elsif version == "2" then
      arxml = export_ecuc_comstack_r422(project:project, messages:messages)
    end

    send_data(
      arxml,
      type: 'application/octet-stream',
      filename: 'Ecuc.arxml'
    )
  end

  def export_systemdesign
    project = Project.find_by_id(session[:project])
    messages = Message.getOwnMessages(session[:project])
    version = QinesVersion.find_by_id(project[:qines_version_id]).qines_version_number

    if version == "1" then
      arxml = export_signals_r403(project:project, messages:messages)
    elsif version == "2" then
      arxml = export_signals_r422(project:project, messages:messages)
    end

    send_data(
      arxml,
      type: 'application/octet-stream',
      filename: 'SystemDesign.arxml'
    )
  end
end
