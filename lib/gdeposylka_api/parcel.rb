# encoding: utf-8
module GdeposylkaApi

  module Parcel

    extend self

    TIMEOUT = 70.freeze

    OPERATONS = {

      'Неудачная попытка вручения' => -1,
      'Приём'             =>  2,
      'Обработка'         =>  3,
      'Досыл'             =>  3,
      'Готов к получению' =>  5,
      'Вручение'          =>  6,
      'Возврат'           =>  7

    }.freeze

    # Загружаем все посылки в сервис для отслеживания
    def load_all

      orders = ::Order.where({

        :delivery_type_id.in => [
          "4f86e26e8a67ad5f0f00000b", # Почта России
          "5100ed648a67adc7f1000026", # Почта России 1 класс (авиа)
          "4f86e26e8a67ad5f0f000006"  # Курьерская почта EMS
        ],
        :state_code => 201

      })

      loaded = 0
      total  = orders.count

      orders.each do |order|

        if !order.delivery_identifier.blank? &&
           !::ParcelTrack.where(:delivery_identifier => order.delivery_identifier).exists?

          if ::ParcelTrack.add(order)
            loaded += 1
          else
            puts "Ошибка обработки заказа: #{order.uri}"
          end

        end # unless

      end # each

      puts "Загружено #{loaded} из #{total}"
      self

    end # load_all

    def add_all

      total = ::ParcelTrack.actual.count
      ::ParcelTrack.actual.with(safe: true).update_all(:checked => false)

      added = 0
      tries = 0

      while(el = ::ParcelTrack.actual.for_check.first)

        result, message, tries = work_with(
          ::GdeposylkaApi::tracks.add(el.delivery_identifier),
          el.delivery_identifier, tries
        ) do |res|
          added += 1
        end

        unless result
          puts message
          next
        end

      end # while

      puts "Добавлено #{added} из #{total}"
      self

    end # add_all

    def update_statuses

      total = ::ParcelTrack.actual.count
      ::ParcelTrack.actual.with(safe: true).update_all(:checked => false)

      checked = 0
      tries   = 0

      while(el = ::ParcelTrack.actual.for_check.first)

        result, message, tries = work_with(
          ::GdeposylkaApi::tracks.status(el.delivery_identifier),
          el.delivery_identifier, tries
        ) do |res|

          datas = get_datas(res, el.delivery_identifier)

          while(data = datas.shift) do

            message       = data[:message]       || data["message"]
            timestamp     = data[:timestamp]     || data["timestamp"]
            service_id    = data[:service_id]    || data["service_id"]
            service_name  = data[:service_name]  || data["service_name"]
            operation     = data[:operation]     || data["operation"]

            next if timestamp.nil? || service_id == "GP"

            unless (message =~ /Прибыло в место вручения/i).nil?
              operation   = 5
            else
              operation   = ::GdeposylkaApi::Parcel::OPERATONS[operation] || -255
            end

            ::ParcelTrack.update_status(el.delivery_identifier, {
              message:      message,
              timestamp:    timestamp,
              service_name: service_name,
              operation:    operation
            })

          end # while

          checked += 1

        end # do

        unless result
          puts message
          next
        end

      end # while

      puts "Обработано #{checked} из #{total}"
      self

    end # update_statuses

    def update_status(delivery_identifier)

      work_with(
        ::GdeposylkaApi::tracks.status(delivery_identifier),
        delivery_identifier
      ) do |res|

        datas = get_datas(res, delivery_identifier)

        while(data = datas.shift) do
          ::ParcelTrack.update_status(delivery_identifier, data)
        end

      end

    end # update_status

    private

    def get_datas(res, delivery_identifier)

      datas = ((res["tracks"] || {})[delivery_identifier.to_s] || {})["info"] || []

      datas.delete_if { |a| a["timestamp"].blank? }
      datas.sort { |a, b| a["timestamp"] <=> b["timestamp"] }

    end # get_datas

    def work_with(res, delivery_identifier, tries = 0)

      if res.empty?
        return [false, "Сервер вернул пустой ответ", tries]
      else

        code = res["response"]["code"]
        if code == 200
          code = ((res["tracks"] || {})[delivery_identifier.to_s] || {})["code"] || -1
        end

        case code

          when 200, 201 then

            ::ParcelTrack.where(:delivery_identifier => delivery_identifier).
              with(safe: true).
              update_all(checked: true)

            yield(res) if block_given?
            return [true, "", tries]

          when 400 then

            return [false, "Неизвестная ошибка. Сервер вернул: #{res.inspect}", tries]

          when 401 then

            return [false, "Неверный ключ API", tries]

          when 402 then

            return [false, "Неправильный формат номера отслеживания: #{delivery_identifier}", tries]

          when 403 then

            ::ParcelTrack.where(:delivery_identifier => delivery_identifier).
              with(safe: true).
              update_all(checked: true)

            return [false, "Неизвестный номер трека: #{delivery_identifier}", tries]

          when 404 then

            return [false, "Не хватает некоторых обязательныx параметров", tries]

          when 405 then

            return [false, "Попытка выполнить не корректное действие над треком", tries]

          when 406 then

            return [false, "При добавлении трека обязателен параметр country", tries]

          when 407 then

            return [false, "Не правильный формат номера телефона", tries]

          when 408 then

            return [false, "Не достаточно средств на счету для выполнения операции", tries]

          when 409 then

            return [false, "Превышено количество треков на данном тарифном плане", tries]

          when 410 then

            puts "Превышена частота запросов на сервер. Ожидаем: #{::Parcel::TIMEOUT} сек."

            tries += 1
            sleep ::Parcel::TIMEOUT

            if tries <= 3
              return [true, "Возобновляем работу", tries]
            else
              return [false, "Закончилось число потпыток: #{tries}", tries]
            end

        else

          return [false, "Неизвестная ошибка. Сервер вернул: #{res.inspect}", tries]

        end # case

      end # if

    end # work_with

  end # Parcel

end # GdeposylkaApi
