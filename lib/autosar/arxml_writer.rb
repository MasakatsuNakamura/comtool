module ArxmlWriter
  require 'rexml/document'
  require 'rexml/formatters/pretty'
  include REXML
  extend self

  def create_arxml(xmlns:'', xsi:'', schemaLocation:'')
    @@document = Document.new
    @@document.context[:attribute_quote] = :quote
    @@document << XMLDecl.new('1.0', 'UTF-8', 'yes')
    autosar = @@document.add_element('AUTOSAR', {'xmlns' => xmlns, 'xmlns:xsi' => xsi, 'xsi:schemaLocation' => schemaLocation})
    @@arpackages = autosar.add_element('AR-PACKAGES')
  end

  def create_arpackage(shortname:'', longname:'', uuid:'', attributes:nil)
    arpackage = @@arpackages.add_element('AR-PACKAGE', {'UUID' => uuid})
    if attributes != nil then
      attributes.each_pair { |key, val|
        arpackage.add_attributes({"#{key}" => "#{val}"})
      }
    end
    arpackage.add_element('SHORT-NAME').add_text(shortname)
    if longname != '' then
      longname_element = arpackage.add_element('LONG-NAME')
      longname_element.add_element('L-4', {'L' => longname.l4}).add_text('')
    end
    @@elements = arpackage.add_element('ELEMENTS')
  end

  def create_ecuc_module_configuration_values(shortname, longname, definitionref,  uuid = '')
    module_configuration_values = @@elements.add_element('ECUC-MODULE-CONFIGURATION-VALUES', {'UUID' => uuid})
    module_configuration_values.add_element('SHORT-NAME').add_text(shortname)
    longname_element = module_configuration_values.add_element('LONG-NAME')
    longname_element.add_element('L-4', {'L' => longname.l4}).add_text('')
    module_configuration_values.add_element('DEFINITION-REF').add_text(definitionref.value)
    return module_configuration_values.add_element('CONTAINERS')
  end

  def create_ecuc_container_value(container, shortname, longname, definitionref, parametervalues = nil, referencevalues = nil, uuid = nil, subcontainers = nil)
    container_values = container.add_element('ECUC-CONTAINER-VALUE', {'UUID' => uuid})
    container_values.add_element('SHORT-NAME').add_text(shortname)
    longname_element = container_values.add_element('LONG-NAME')
    longname_element.add_element('L-4', {'L' => longname.l4}).add_text('')
    container_values.add_element('DEFINITION-REF', {'DEST' => definitionref.dest}).add_text(definitionref.value)
    if parametervalues != nil
      parametervalues_element = container_values.add_element('PARAMETER-VALUES')
      parametervalues.each_value { |parametervalue|
        parametervalue_element = parametervalues_element.add_element(parametervalue.type)
        parametervalue_element.add_element('DEFINITION-REF', {'DEST' => parametervalue.definitionref.dest}).add_text(parametervalue.definitionref.value)
        parametervalue_element.add_element('VALUE').add_text(parametervalue.value)
      }
    end
    if referencevalues != nil
      referencevalues_element = container_values.add_element('REFERENCE-VALUES')
      referencevalues.each_value { |referencevalue|
        referencevalue_element = referencevalues_element.add_element('ECUC-REFERENCE-VALUE')
        referencevalue_element.add_element('DEFINITION-REF', {'DEST' => referencevalue.definitionref.dest}).add_text(referencevalue.definitionref.value)
        referencevalue_element.add_element('VALUE-REF', {'DEST' => referencevalue.valueref.dest}).add_text(referencevalue.valueref.value)
      }
    end
    if subcontainers != nil
      return container_values.add_element('SUB-CONTAINERS')
    else
      return nil
    end
  end

  def create_systemsignal(shortname:'', uuid:'')
    systemsignal = @@elements.add_element('SYSTEM-SIGNAL', {'UUID' => uuid})
    systemsignal.add_element('SHORT-NAME').add_text(shortname)
  end

  def create_isignal(shortname:'', systemsignalref:nil, uuid:'')
    isignal = @@elements.add_element('I-SIGNAL', {'UUID' => uuid})
    isignal.add_element('SHORT-NAME').add_text(shortname)
    isignal.add_element('SYSTEM-SIGNAL-REF', {'DEST' => systemsignalref.dest}).add_text(systemsignalref.value)
  end

  def create_isignalpdu(shortname:'', uuid:'', isignaltoipdumappings:nil)
    isignalpdu = @@elements.add_element('I-SIGNAL-I-PDU', {'UUID' => uuid})
    isignalpdu.add_element('SHORT-NAME').add_text(shortname)
    isignaltoipdumappings_element = isignalpdu.add_element('I-SIGNAL-TO-I-PDU-MAPPINGS')
    isignaltoipdumappings.each_value { |isignaltoipdumapping|
      isignaltoipdumapping_element = isignaltoipdumappings_element.add_element('I-SIGNAL-TO-I-PDU-MAPPING', {'UUID' => isignaltoipdumapping.uuid})
      isignaltoipdumapping_element.add_element('SHORT-NAME').add_text(isignaltoipdumapping.shortname)
      isignaltoipdumapping_element.add_element('I-SIGNAL-REF', {'DEST' => isignaltoipdumapping.isignalref.dest}).add_text(isignaltoipdumapping.isignalref.value)
    }
  end

  def output_arxml
    formatter = Formatters::Pretty::new(4)
    formatter.compact = true
    formatter.width = 500

    arxml = ''
    formatter.write(@@document, arxml)
    return arxml
  end
end
