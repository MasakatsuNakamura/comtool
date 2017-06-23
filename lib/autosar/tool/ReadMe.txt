参考：
ABREXの使い方
https://dev.toppers.jp/trac_user/ap/wiki/tips_abrex


arxml出力時に使用される、パラメータ情報ファイルを作成するツールです。

１．AUTOSAR_MOD_ECUConfigurationParameters.arxmlからパラメータ情報ファイルを作成する場合

>ruby make_para_info.rb -p stmdファイル

２．VSMDのフォルダにあるファイルからパラメータ情報ファイルを作成する場合

>ruby make_para_info.rb -d  vsmdフォルダ


必要なモジュールを変更したい場合

make_para_info.rbの6行目

TARGET_MODULE = %w[Com PduR CanIf EcuC BswM].freeze

を変更してください。

