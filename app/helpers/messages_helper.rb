module MessagesHelper

  def to_js (message)
    {byte_order: Project.find_by_id(message.project_id).byte_order_before_type_cast}.to_json
  end

end
