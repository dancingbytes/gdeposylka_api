# encoding: utf-8
require 'net/http'

module GdeposylkaApi

  class Base

    def initialize(api_key)
      @api_key = api_key
    end # new

    # Список отправлений
    def list(area = "main")

      data = {}
      block_run do |http|

        uri = request("list", {
          area: area
        })

        log("[list] => #{uri}")
        res  = http.get(uri)
        log("[list] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # list

    # Добавить отправление
    def add(id, async = true, country = "RU", descr = nil)

      data = {}
      block_run do |http|

        uri = request("add", {
          id:       id,
          async:    async,
          country:  country,
          descr:    descr
        })

        log("[add] => #{uri}")
        res  = http.get(uri)
        log("[add] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # add

    # Статус отправления (информация об отправлении)
    def status(id)

      data = {}
      block_run do |http|

        uri = request("status", {
          id: id
        })

        log("[status] => #{uri}")
        res  = http.get(uri)
        log("[status] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # status

    # Изменить срану назначения посылки
    def country(id, name)

      data = {}
      block_run do |http|

        uri = request("country", {
          id:       id,
          country:  name
        })

        log("[country] => #{uri}")
        res  = http.get(uri)
        log("[country] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # country

    # Включить SMS уведомление для трека
    def sms(id, phone, descr, greeting)

      data = {}
      block_run do |http|

        uri = request("sms", {
          id:         id,
          phone:      phone,
          descr:      descr,
          greeting:   greeting
        })

        log("[sms] => #{uri}")
        res  = http.get(uri)
        log("[sms] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # sms

    # Возобносить отслеживание отправления
    def resume(id)

      data = {}
      block_run do |http|

        uri = request("resume", {
          id: id
        })

        log("[resume] => #{uri}")
        res  = http.get(uri)
        log("[resume] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # resume

    # Получить географические координаты почтового отделения
    def points(ops)

      data = {}
      block_run do |http|

        uri = request("points", {
          ops: ops
        })

        log("[points] => #{uri}")
        res  = http.get(uri)
        log("[points] <= #{res.body}")

        data = ::JSON.parse(res.body) rescue {}

      end # block_run
      data

    end # points

    private

    def request(func, datas = {})

      datas.delete_if { |k, v| v.nil? || v == '' }

      uri =  "/#{::GdeposylkaApi::API_VERSION}"
      uri << "/track.#{func}"
      uri << "/json/?apikey=#{::GdeposylkaApi.api_key}"

      unless datas.empty?
        uri << "&"
        uri << ::URI.encode_www_form(datas)
      end

      uri

    end # request

    def log(msg)

      puts(msg) if ::GdeposylkaApi.debug?
      self

    end # log

    def block_run

      ::Net::HTTP.start( ::GdeposylkaApi::HOST, :use_ssl => ::GdeposylkaApi::USE_SSL ) do |http|

        begin
          yield(http)
        rescue => e
          puts e.message
          puts e.backtrace.join("\n")
        end

      end

    end # block_run

  end # Base

end # GdeposylkaApi
