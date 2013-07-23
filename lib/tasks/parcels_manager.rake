# encoding: utf-8
namespace :gdeposylka_api do

  desc 'Загрузка данных для ослеживания.'
  task :parcels_load_all => :environment do

    ::GdeposylkaApi::Parcel.load_all

  end # :parcels_load_all

  desc 'Добавление треков сервис http://gdeposylka.ru'
  task :parcels_add_all => :environment do

    ::GdeposylkaApi::Parcel.add_all

  end # :parcels_add_all

  desc 'Обновление статусов заказов.'
  task :parcels_update_status => :environment do

    ::GdeposylkaApi::Parcel.update_statuses

  end # :parcels_update_status

end # :gdeposylka_api

# bundle exec rake gdeposylka_api:parcels_load_all --trace
# bundle exec rake gdeposylka_api:parcels_add_all --trace
# bundle exec rake gdeposylka_api:parcels_update_status --trace
