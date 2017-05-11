class ConfigController < ApplicationController
  include ArxmlExporter_r403
  include ArxmlExporter_r422

  def export_ecuc
    project = Project.find(session[:project])
    messages = Message.where(project_id: session[:project])
    version = project[:qines_version_id]

    if version == 'v1_0'
      arxml = export_ecuc_comstack_r403(project: project, messages: messages)
    elsif version == 'v2_0'
      arxml = export_ecuc_comstack_r422(project: project, messages: messages)
    else
      raise 'invalid qines version'
    end

    send_data(
      arxml,
      type: 'application/octet-stream',
      filename: 'Ecuc.arxml'
    )
  end

  def export_systemdesign
    project = Project.find(session[:project])
    messages = Message.where(project_id: session[:project])
    version = project[:qines_version_id]

    if version == 'v1_0'
      arxml = export_signals_r403(project: project, messages: messages)
    elsif version == 'v2_0'
      arxml = export_signals_r422(project: project, messages: messages)
    else
      raise 'invalid qines version'
    end

    send_data(
      arxml,
      type: 'application/octet-stream',
      filename: 'SystemDesign.arxml'
    )
  end
end
