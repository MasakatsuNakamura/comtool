module MessagesHelper

  def byte_order_of (message)
    Project.find_by_id(message.project_id).byte_order
  end
end
