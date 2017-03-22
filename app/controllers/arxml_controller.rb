class ArxmlController < ApplicationController
  def new; end

  def create
    xml = Nokogiri::XML(File.open("test\arxml\Ecuc.arxml"))
    p xml
  end
end
