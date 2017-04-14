# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
CommunicationProtocol.create!(name: 'CAN', protocol_number: "1")
QinesVersion.create!(name: 'V1.0', qines_version_number: "1")
Project.create!(name: 'TestProject', communication_protocol_id: '1', qines_version_id: '1')
Sign.create!(name: 'TestSign', active: '1', vartype:'2', unit:'3',
exchange_rate:'4.0', priority:'5', input_module:'6', output_moduel:'7',
input_period:'8', output_period:'9', access_level:'10', project_id:'1',
description:'テスト用の符号です')
DatabaseManage.delete_all
# DatabaseManage.connection.execute("TRUNCATE TABLE DatabaseManage;")   # TRUNCATEはsqlite3はエラー
DatabaseManage.create!(backup_file_path: 'CAN/test',backup_date: Date.today, project_id: 1)
Config.create!(item: '２０１７／３／１ CAN TEST1', value: '値１', project_id: 1, sign_id: 1, description:'テスト用のコンフィグです', message_id:1)
Config.create!(item: '２０１７／３／１ CAN TEST2', value: '値１', project_id: 2, sign_id: 2, description:'テスト用のコンフィグです', message_id:2)
