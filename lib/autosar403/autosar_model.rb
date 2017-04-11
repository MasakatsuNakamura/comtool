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
  def to_arxml

    create_arxml("http://autosar.org/schema/r4.0")
    @arpackages.each_value { |arpackage|
      create_arpackage(arpackage.shortname, arpackage.longname)
      arpackage.elements.each_value { |element|
        if element.instance_of?(EcucModuleConfigurationValue) then
          root_container = create_ecuc_module_configuration_values(element.shortname, element.longname, element.definitionref, element.uuid)
          create_container(root_container, element.containers)
        end
      }
    }
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
  attr_accessor :shortname, :longname, :elements
end

class EcucModuleConfigurationValue < AutosarBase
  attr_accessor :shortname, :longname, :definitionref, :uuid, :containers
end

class EcucContainerValue < AutosarBase
  attr_accessor :shortname, :longname, :definitionref, :parametervalues, :referencevalues, :uuid, :subcontainers
end

class SystemSignal < AutosarBase

end

class Isignal < AutosarBase

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
