  METHOD prepare_update_invoice.
*    IF get_batch_header(  ) = 'X'.
*      rv_request = get_dts_detail( iv_trftype = 'M' ).
*    ELSE.
*    ENDIF.
    DATA lv_amount TYPE string.
    DATA lv_waers TYPE waers.
    lv_amount = ms_invoice_data-invoiceamount.CONDENSE lv_amount.
    IF ms_invoice_data-transactioncurrency EQ 'TRY'.
      lv_waers = 'TL'.
    ELSE.
      lv_waers = ms_invoice_data-transactioncurrency.
    ENDIF.
    mv_batch_id = get_batchid(  ).
    mv_trf_id = get_trfid(  ).
    CONCATENATE
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pay="PaymentService">'
        '<soapenv:Header/>'
        '<soapenv:Body>'
            '<pay:OnlinePaymentRequest>'
                '<pay:SPName>' ms_service_info-additional_field1 '</pay:SPName>'
                '<pay:GLCN>' ms_service_info-additional_field2 '</pay:GLCN>'
                '<pay:Operation>DTS</pay:Operation>'
                '<pay:BatchID>' mv_batch_id '</pay:BatchID>'
                '<pay:RegionCode/>'
                '<pay:TrfUniqueID>' mv_trf_id '</pay:TrfUniqueID>'
                '<pay:TrfType>MA</pay:TrfType>'
                '<pay:ContractID>' ms_subscribe-subscriber_number '</pay:ContractID>'
                '<pay:InvoiceType>B</pay:InvoiceType>'
                '<pay:InvoiceNumber>' ms_invoice_data-invoicenumber '</pay:InvoiceNumber>'
                '<pay:InvoiceDate>' ms_invoice_data-documentdate '</pay:InvoiceDate>'
                '<pay:DueDate>' ms_invoice_data-invoiceduedate '</pay:DueDate>'
                '<pay:Amount>' lv_amount '</pay:Amount>'
                '<pay:CurrCode>' lv_waers '</pay:CurrCode>'
                '<!--Optional:-->'
                '<pay:Name></pay:Name>'
                '<!--Optional:-->'
                '<pay:CreditContractID/>'
                '<!--Optional:-->'
                '<pay:PaymentType/>'
            '</pay:OnlinePaymentRequest>'
        '</soapenv:Body>'
    '</soapenv:Envelope>' INTO rv_request.
  ENDMETHOD.