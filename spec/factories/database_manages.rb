FactoryGirl.define do
  factory :database_manage do
    backup_file_path "MyString"
    backup_date "2017-03-10"
    project nil
  end
end
