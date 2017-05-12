require 'strscan'

module MessagesHelper

  def to_js (message)
    {byte_order: Project.find_by_id(message.project_id).byte_order_before_type_cast}.to_json
  end

  class FileParser
    def self.keyword(pattern)
      capture(nil, pattern)
    end

    def self.capture(name, pattern)
      if name.nil? then
        "(#{pattern})"
      else
        "(?<#{name}>#{pattern})"
      end
    end

    def self.literal(pattern)
      Regexp.escape(pattern)
    end

    def self.group(*args)
      "\\s*(?:#{args.join('\s*')}\\s*){1,1}?"
    end

    def self.one_or_more(pattern)
      pattern + "+?"
    end

    def self.zero_or_more(pattern)
      pattern + "*?"
    end
  end

  class DbcFileParser < FileParser

    # DBC section types
    COMMENT = 'CM_'
    MESSAGE = 'BO_'
    SIGNAL  = 'SG_'

    def self.setup_grammar
      grammar = {}

      integer = '-*\d+'
      word    = '[\w:]+'
      number  = '-?[-\+\d.Ee]+'
      sign    = '[-\+]'
      quotedString = '[^"]*'

      # _で始まるシンボルはインポート対象外
      signal  = group(keyword(SIGNAL),
                      capture(:name, word),
                      literal(':'),
                      capture(:bit_offset,  integer),
                      literal('|'),
                      capture(:bit_size,    integer),
                      literal('@'),
                      capture(:_byte_order, integer),
                      capture(:_value_type, sign),
                      literal('('),
                      capture(:_scale,      number),
                      literal(','),
                      capture(:_offset,     number),
                      literal(')'),
                      literal('['),
                      capture(:_min,        number),
                      literal('|'),
                      capture(:_max,        number),
                      literal(']'),
                      literal('"'),
                      capture(:unit,        quotedString),
                      literal('"'),
                      capture(:_receiver,   word),
                )

      grammar[:signal] = signal

      # _で始まるシンボルはインポート対象外
      message = group(keyword(MESSAGE),
                      capture(:canid,         integer),
                      capture(:name,          word),
                      literal(':'),
                      capture(:bytesize,      integer),
                      capture(:_transmitter,  word)
                )
      grammar[:message] = message

      # _で始まるシンボルはインポート対象外
      comment_signal =  group(keyword(COMMENT),
                              capture(:_subkey,   SIGNAL),
                              capture(:_canid, integer),
                              capture(:_sig_name, word),
                              literal('"'),
                              capture(:description,  quotedString),
                              literal('"'),
                              literal(';')
                        )
      grammar[:comment_signal] = comment_signal

      grammar
    end

    def self.matched_captures(fmt, scanner)
      /#{fmt}/.match(scanner.matched).named_captures.symbolize_keys
    end

    def self.import_captures(fmt, scanner)
      matched_captures(fmt, scanner).delete_if {|k,v| k =~ /\A_/}
    end

    def self.import_data_type(cap)
      signed = cap[:_value_type] == '-'

      case cap[:bit_size].to_i
      when 0..1
        signed ? 'sint8'  : 'boolean'
      when 2..8
        signed ? 'sint8'  : 'uint8'
      when 9..16
        signed ? 'sint16' : 'uint16'
      when 17..32
        signed ? 'sint32' : 'uint32'
      when 33..64
        signed ? 'sint64' : 'uint64'
      else
        'other'
      end
    end

    def self.parse(project, string)
      s = StringScanner.new(string)

      grammar = setup_grammar

      messages = {}

      begin
        until s.eos?
          if s.scan(/#{grammar[:message]}\R*/)
            args = import_captures(grammar[:message], s)
            args.merge! ({project_id:project.id})
            m = Message.new(args)

            while s.scan(/#{grammar[:signal]}\R*/)
              cap  = matched_captures(grammar[:signal], s)
              args = import_captures(grammar[:signal], s)
              args.merge!(
                { data_type: import_data_type(cap),
                  project_id:project.id,
                  message: m,
                }
              )
              m.com_signals.build args
            end

            messages[m.canid.to_s] = m

          elsif s.scan(/#{grammar[:comment_signal]}\R*/)
            cap = matched_captures(grammar[:comment_signal], s)

            messages[cap[:_canid]].com_signals.each do |ss|
              ss.description = cap[:description] if ss.name == cap[:_sig_name]
            end

          elsif s.scan(/.+\R*/)
            #p "skiped. #{s.matched}"
          else
            raise "scanner error"
          end
        end

        messages.values
      end
    rescue => e
      nil
    end
  end

  class DbcFileGenerator

DBC_FMT = """%{version}

NS_ :
\tNS_DESC_
\tCM_
\tBA_DEF_
\tBA_
\tVAL_
\tCAT_DEF_
\tCAT_
\tFILTER
\tBA_DEF_DEF_
\tEV_DATA_
\tENVVAR_DATA_
\tSGTYPE_
\tSGTYPE_VAL_
\tBA_DEF_SGTYPE_
\tBA_SGTYPE_
\tSIG_TYPE_REF_
\tVAL_TABLE_
\tSIG_GROUP_
\tSIG_VALTYPE_
\tSIGTYPE_VALTYPE_

BS_:

%{bu}

%{bo}

%{cm}
"""

    def self.export_byte_order(com_signal)
      com_signal.message.project.little_endian? ? '0' : '1'
    end

    def self.export_value_type(com_signal)
      # + for unsigned, - for signed
      value_type = '-'
      %w(boolean uint).each {|a| value_type = '+' if com_signal.data_type.include? a}
      value_type
    end

    def self.export_min(com_signal)
      min = {
        sint8:   -1*(2<<6),
        sint16:  -1*(2<<14),
        sint32:  -1*(2<<30),
        sint64:  -1*(2<<62),
        float32: -3.4e+38,
        float64: -1.7e+308,
      }.[] com_signal.data_type.to_sym
      min.nil? ? '0' : min.to_s
    end

    def self.export_max(com_signal)
      max = {
        boolean: 1,
        uint8:   (2<<7)-1,
        uint16:  (2<<15)-1,
        uint32:  (2<<31)-1,
        uint64:  (2<<63)-1,
        sint8:   (2<<6)-1,
        sint16:  (2<<14)-1,
        sint32:  (2<<30)-1,
        sint64:  (2<<62)-1,
        float32: 3.4e+38,
        float64: 1.7e+308,
      }.[] com_signal.data_type.to_sym
      max.nil? ? '0' : max.to_s
    end

    def self.version_format(project)
      'VERSION ""'
    end

    def self.bu_format(project)
      "BU_: #{project.name}"
    end

    def self.bo_sg_format(project)
      bo = ""

      messages = Message.where(project_id:project.id).order(:id)

      messages.each do | m |
        args = m.attributes.symbolize_keys
        args.merge! ({
          _transmitter:'Vector_XXX',
        })
        bo += 'BO_ %{canid} %{name}: %{bytesize} %{_transmitter}\n' % args

        com_signals = ComSignal.where(message_id:m.id).order(:id)
        com_signals.each do | s |
          args = s.attributes.symbolize_keys
          args.merge! ({
            _byte_order:export_byte_order(s),
            _value_type:export_value_type(s),
            _scale:1,
            _offset:0,
            _min:export_min(s),
            _max:export_max(s),
            _receiver:'Vector_XXX',
          })
          bo += ' SG_ %{name} : %{bit_offset}|%{bit_size}@%{_byte_order}%{_value_type} (%{_scale},%{_offset}) [%{_min}|%{_max}] "%{unit}" %{_receiver}\n' % args
        end
        bo += '\n'
      end

      bo.chomp('\n\n')
    end

    def self.cm_format(project)
      cm = ""

      messages = Message.where(project_id:project.id)

      messages.each do | m |
        com_signals = ComSignal.where(message_id:m.id).order(:id)
        com_signals.each do | s |
          args = s.attributes.symbolize_keys
          args.merge! ({
            canid: s.message.canid,
          })
          cm += 'CM_ SG_ %{canid} %{name} "%{description}";\n' % args unless s.description.nil?
        end
      end

      cm.chomp('\n')
    end

    def self.generate( project )
      sprintf(DBC_FMT,
        version: version_format(project),
        bu:      bu_format(project),
        bo:      bo_sg_format(project),
        cm:      cm_format(project)
      ).gsub(/\\n/,"\n")
    end
  end

  def import_messages(project_id, messages)
    import_info = {}
    begin
      Message.transaction do
        messages.each do |m|
          exist_message = Message.find_by(name:m.name, project_id:project_id)
          if exist_message.nil?
            raise unless m.save
          else
            message_id = exist_message.id

            update_params = m.attributes.select { |k,v| k == :canid || k == :bytesize}
            raise unless exist_message.update_attributes update_params

            m.com_signals.each do |s|
              exist_com_signal = ComSignal.find_by(name:s.name, project_id:project_id)
              if exist_com_signal.nil?
                raise unless s.save
              else
                update_params = s.attributes.select { |k,v|
                  k == :description || k == :offset || k == :bit_size || k == :data_type || k == :unit }
                raise unless exist_com_signal.update_attributes update_params
              end
            end
          end
        end
      end

      import_info[:info] = ['メッセージをインポートしました。']
      messages.each do |m|
        signames = ""
        m.com_signals.each {|s| signames += s.name + ', ' }
        import_info[:info] << m.name + ' ( ' + signames + " ) "
      end
    rescue => e
      if messages.nil? then
        import_info[:danger] = ['サポートされないフォーマットです']
      else
        import_info[:danger] = ['インポートに失敗しました。']
        messages.each do |m|
          m.errors.full_messages.each {|msg|
            import_info[:danger] << m.name + ' => ' + msg
          }
        end
      end
    end

    import_info
  end
end
