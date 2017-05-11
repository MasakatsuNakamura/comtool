class AutosarBase
  def initialize(attributes = nil)
     attributes.each do |k, v|
       send("#{k.to_s}=", v) if respond_to?("#{k.to_s}=")
     end if attributes
   end
end

class Autosar < AutosarBase
  attr_accessor :arpackages

  include ArxmlWriter
  def to_arxml(version:'r422', kind:'Ecuc')
    xsd = version == 'r422' ? 'autosar_4-2-2.xsd' : 'autosar_4-0-3.xsd'
    create_arxml(xmlns:'http://autosar.org/schema/r4.0', xsi:'http://www.w3.org/2001/XMLSchema-instance',
                                        schemaLocation:"http://autosar.org/schema/r4.0 #{xsd}", version:version)
    if kind == 'Ecuc' then
      @arpackages.each_value { |arpackage|
        create_arpackage(shortname:arpackage.shortname, longname:arpackage.longname, uuid:arpackage.uuid)
        arpackage.elements.each_value { |element|
          edition = (version == 'r422') ? '4.2.2' : nil
          root_container = create_ecuc_module_configuration_values(element.shortname, element.longname, element.definitionref, element.uuid, edition:edition)
          create_container(root_container, element.containers)
        }
      }
    elsif kind == 'SystemDesign' then
      @arpackages.each_value { |arpackage|
        attributes = Hash.new([])
        attributes[:S] = ''
        create_arpackage(shortname:arpackage.shortname, uuid:arpackage.uuid, attributes:attributes)
        arpackage.elements.each_value { |element|
          if element.instance_of?(SystemSignal) then
            create_systemsignal(shortname:element.shortname, uuid:element.uuid)
          elsif element.instance_of?(ISignal) then
            create_isignal(shortname:element.shortname, systemsignalref:element.systemsignalref, uuid:element.uuid)
          elsif element.instance_of?(ISignalIPdu) then
            create_isignalpdu(shortname:element.shortname, uuid:element.uuid, isignaltoipdumappings:element.isignaltoipdumappings)
          end
        }
      }
    end
    return output_arxml()
  end

  private
  def create_container(rexml_element_container, containers)
    containers.each_value { |container|
      rexml_element_subcontainer = create_ecuc_container_value(rexml_element_container, container.shortname, container.longname, container.definitionref,
                                                            container.parametervalues, container.referencevalues, container.uuid, container.subcontainers)
      if rexml_element_subcontainer != nil
        create_container(rexml_element_subcontainer, container.subcontainers)
      end
    }
  end
end

class ArPackage < AutosarBase
  attr_accessor :shortname, :longname, :uuid, :elements
end

class EcucModuleConfigurationValue < AutosarBase
  attr_accessor :shortname, :longname, :definitionref, :uuid, :containers
end

class EcucContainerValue < AutosarBase
  attr_accessor :shortname, :longname, :definitionref, :parametervalues, :referencevalues, :uuid, :subcontainers
end

class LongName < AutosarBase
    attr_accessor :l4
end

class DefinitionRef < AutosarBase
  attr_accessor :dest, :value
end

class ValueRef < AutosarBase
  attr_accessor :dest, :value
end

class ParameterValue < AutosarBase
  attr_accessor :type, :definitionref, :value
end

class ReferenceValue < AutosarBase
  attr_accessor :definitionref, :valueref
end

class SystemSignal < AutosarBase
  attr_accessor :shortname, :uuid
end

class ISignal < AutosarBase
  attr_accessor :shortname, :systemsignalref, :uuid
end

class ISignalIPdu < AutosarBase
  attr_accessor :shortname, :uuid, :isignaltoipdumappings
end

class ISignalToIPduMapping < AutosarBase
  attr_accessor :shortname, :isignalref, :uuid
end

class SystemSignalRef < AutosarBase
  attr_accessor :dest, :value
end

class ISignalRef < AutosarBase
  attr_accessor :dest, :value
end
