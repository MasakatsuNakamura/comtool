module ArxmlWriter
  require 'rexml/document'
  require 'rexml/formatters/pretty'
  include REXML
  extend self

  def create_arxml(schema)
    @@document = Document.new
    @@document.context[:attribute_quote] = :quote
    @@document << XMLDecl.new('1.0', 'UTF-8', 'yes')
    autosar = @@document.add_element("AUTOSAR", {"xmlns" => schema})
    @@arpackages = autosar.add_element("AR-PACKAGES")
  end

  def create_arpackage(shortname, longname)
    arpackage = @@arpackages.add_element("AR-PACKAGE")
    arpackage.add_element("SHORT-NAME").add_text(shortname)
    longname_element = arpackage.add_element("LONG-NAME")
    longname_element.add_element("L-4", {"L" => longname.l4}).add_text("")
    @@elements = arpackage.add_element("ELEMENTS")
  end

  def create_ecuc_module_configuration_values(shortname, longname, definitionref,  uuid = nil)
    module_configuration_values = @@elements.add_element("ECUC-MODULE-CONFIGURATION-VALUES", {"UUID" => uuid})
    module_configuration_values.add_element("SHORT-NAME").add_text(shortname)
    longname_element = module_configuration_values.add_element("LONG-NAME")
    longname_element.add_element("L-4", {"L" => longname.l4}).add_text("")
    module_configuration_values.add_element("DEFINITION-REF").add_text(definitionref.value)
    return module_configuration_values.add_element("CONTAINERS")
  end

  def create_ecuc_container_value(container, shortname, longname, definitionref, parametervalues = nil, referencevalues = nil, uuid = nil, subcontainers = nil)
    container_values = container.add_element("ECUC-CONTAINER-VALUE", {"UUID" => uuid})
    container_values.add_element("SHORT-NAME").add_text(shortname)
    longname_element = container_values.add_element("LONG-NAME")
    longname_element.add_element("L-4", {"L" => longname.l4}).add_text("")
    container_values.add_element("DEFINITION-REF", {"DEST" => definitionref.dest}).add_text(definitionref.value)
    if parametervalues != nil
      parametervalues_element = container_values.add_element("PARAMETER-VALUES")
      parametervalues.each_value { |parametervalue|
        parametervalue_element = parametervalues_element.add_element(parametervalue.type)
        parametervalue_element.add_element("DEFINITION-REF", {"DEST" => parametervalue.definitionref.dest}).add_text(parametervalue.definitionref.value)
        parametervalue_element.add_element("VALUE").add_text(parametervalue.value)
      }
    end
    if referencevalues != nil
      referencevalues_element = container_values.add_element("REFERENCE-VALUES")
      referencevalues.each_value { |referencevalue|
        referencevalue_element = referencevalues_element.add_element("ECUC-REFERENCE-VALUE")
        referencevalue_element.add_element("DEFINITION-REF", {"DEST" => referencevalue.definitionref.dest}).add_text(referencevalue.definitionref.value)
        referencevalue_element.add_element("VALUE-REF", {"DEST" => referencevalue.valueref.dest}).add_text(referencevalue.valueref.value)
      }
    end
    if subcontainers != nil
      return container_values.add_element("SUB-CONTAINERS")
    else
      return nil
    end
  end

  def output_arxml
    formatter = Formatters::Pretty::new(4)
    formatter.compact = true
    formatter.width = 500

    arxml = ""
    formatter.write(@@document, arxml)
    return arxml
  end
end
