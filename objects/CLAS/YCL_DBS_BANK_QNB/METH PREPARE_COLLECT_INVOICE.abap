  METHOD prepare_collect_invoice.
    CONCATENATE
*  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nan="http://nanopetdbs.driver.maestro.ibtech.com">'
  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:' ms_service_info-additional_field2 '>'
     '<soapenv:Header/>'
     '<soapenv:Body>'
*        '<nan:akibetSorgula>'
        '<' ms_service_info-additional_field1 ':akibetSorgula>'
           '<!--Optional:-->'
           '<akibetSorgulaRequest>'
              '<!--Optional:-->'
              '<baslangicVadeTarihi>' ms_invoice_data-documentdate '</baslangicVadeTarihi>'
              '<!--Optional:-->'
              '<bayiReferans>' ms_subscribe-subscriber_number '</bayiReferans>'
              '<!--Optional:-->'
              '<bitisVadeTarihi>' ms_invoice_data-invoiceduedate '</bitisVadeTarihi>'
              '<!--Optional:-->'
              '<faturaNo>' ms_invoice_data-invoicenumber '</faturaNo>'
              '<!--Optional:-->'
              '<password>' ms_service_info-password '</password>'
              '<!--Optional:-->'
              '<userName>' ms_service_info-username '</userName>'
           '</akibetSorgulaRequest>'
*        '</nan:akibetSorgula>'
        '</' ms_service_info-additional_field1 ':akibetSorgula>'
     '</soapenv:Body>'
  '</soapenv:Envelope>' INTO rv_request.

  ENDMETHOD.