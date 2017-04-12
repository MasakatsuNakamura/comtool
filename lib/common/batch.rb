class BatchExport
  # バッチ実行
  def invoke(tablename,outfile)
    rtn = false
    case tablename
      when :signs, :configs
        rtncd = system( "#{ComConst::DbAdapter} #{ComConst::DatabaseDir} \".dump \'#{tablename.to_s}\'\" > #{outfile}")
        rtncd = outfile if rtncd
      else
    end
    rtncd
  end
end
