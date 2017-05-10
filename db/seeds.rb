# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
CommunicationProtocol.find_or_create_by(name:'CAN') {|v| v.protocol_number = '1'}

QinesVersion.find_or_create_by(name:'V1.0') {|v| v.qines_version_number = '1'}
QinesVersion.find_or_create_by(name:'V2.0') {|v| v.qines_version_number = '2'}

DatabaseManage.delete_all
# DatabaseManage.connection.execute("TRUNCATE TABLE DatabaseManage;")   # TRUNCATEはsqlite3はエラー
DatabaseManage.create!(backup_file_path: 'CAN/test',backup_date: Date.today, project_id: 1)
Config.create!(item: '２０１７／３／１ CAN TEST1', value: '値１', project_id: 1, sign_id: 1, description:'テスト用のコンフィグです', message_id:1)
Config.create!(item: '２０１７／３／１ CAN TEST2', value: '値１', project_id: 2, sign_id: 2, description:'テスト用のコンフィグです', message_id:2)
