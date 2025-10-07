  METHOD prepare_collect_invoice.
    SELECT SINGLE trf_id
    FROM ydbs_t_log
    WHERE companycode = @ms_invoice_data-companycode
      AND accountingdocument = @ms_invoice_data-accountingdocument
      AND accountingdocumentitem = @ms_invoice_data-accountingdocumentitem
    INTO @DATA(lv_trf_id).
    CONCATENATE
  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pay="PaymentService">'
     '<soapenv:Header/>'
     '<soapenv:Body>'
        '<pay:SingleTrfRequest>'
           '<pay:SPName>' ms_service_info-additional_field1 '</pay:SPName>'
           '<pay:GLCN>' ms_service_info-additional_field2 '</pay:GLCN>'
           '<!--Optional:-->'
           '<pay:CreateTimestamp></pay:CreateTimestamp>'
           '<!--Optional:-->'
           '<pay:SecureToken></pay:SecureToken>'
           '<pay:TrfUniqueID>' lv_trf_id '</pay:TrfUniqueID>'
        '</pay:SingleTrfRequest>'
     '</soapenv:Body>'
  '</soapenv:Envelope>' INTO rv_request.

  ENDMETHOD.