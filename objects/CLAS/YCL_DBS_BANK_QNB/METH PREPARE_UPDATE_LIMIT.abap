  METHOD prepare_update_limit.
    CONCATENATE
*  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nan="http://nanopetdbs.driver.maestro.ibtech.com">'
  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:' ms_service_info-additional_field2 '>'
      '<soapenv:Header/>'
      '<soapenv:Body>'
*          '<nan:limitSorgula>'
          '<' ms_service_info-additional_field1 ':limitSorgula>'
              '<!--Optional:-->'
              '<limitSorgulaRequest>'
                 '<!--Optional:-->'
                  '<bayiReferans>' ms_subscribe-subscriber_number '</bayiReferans>'
                  '<!--Optional:-->'
                  '<password>' ms_service_info-password '</password>'
                  '<!--Optional:-->'
                  '<userName>' ms_service_info-username '</userName>'
              '</limitSorgulaRequest>'
*          '</nan:limitSorgula>'
          '</' ms_service_info-additional_field1 ':limitSorgula>'
      '</soapenv:Body>'
  '</soapenv:Envelope>' INTO rv_request.

  ENDMETHOD.