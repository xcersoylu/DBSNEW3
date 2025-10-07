  METHOD prepare_collect_invoice.
    DATA : lv_amount    TYPE string,
           lv_waers     TYPE waers,
           lv_vade      TYPE c LENGTH 10.
    lv_amount = ms_invoice_data-invoiceamount.
    CONDENSE lv_amount.

    IF ms_invoice_data-transactioncurrency EQ 'TRY'.
      lv_waers = 'TL'.
    ELSE.
      lv_waers = ms_invoice_data-transactioncurrency.
    ENDIF.

    CONCATENATE ms_invoice_data-invoiceduedate+6(2) '/'
                ms_invoice_data-invoiceduedate+4(2) '/'
                ms_invoice_data-invoiceduedate(4)
           INTO lv_vade.

    CONCATENATE
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:com="http://com.teb.tebdbs/">'
    '<soapenv:Header/>'
    '<soapenv:Body>'
    '<com:TEBDBSFaturaAkibetSorguV2>'
    '<com:kullaniciAdi>' ms_service_info-username '</com:kullaniciAdi>'
    '<com:sifre>' ms_service_info-password '</com:sifre>'
    '<com:anaFirma>' ms_service_info-additional_field1 '</com:anaFirma>'
    '<com:firmaMusteriNo>' ms_subscribe-subscriber_number '</com:firmaMusteriNo>'
    '<com:faturaNo>' ms_invoice_data-invoicenumber '</com:faturaNo>'
    '<com:tutar>' lv_amount '</com:tutar>'
    '<com:paraKod>' lv_waers '</com:paraKod>'
    '<com:faturaVade>' lv_vade '</com:faturaVade>'
    '<com:satisTmslBilgi></com:satisTmslBilgi>'
    '</com:TEBDBSFaturaAkibetSorguV2>'
    '</soapenv:Body>'
    '</soapenv:Envelope>' INTO rv_request.

  ENDMETHOD.