require 'fileutils'
class MakeDir
  # ディレクトリ dir とその親ディレクトリを全て作成します。
  def self.mkdir(directory)
    unless Dir.exist?(directory)
      FileUtils.mkdir_p(directory,{mode: 0777})
    end
  end
end
