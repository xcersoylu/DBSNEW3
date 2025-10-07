  METHOD prepare_update_invoice.
    DATA: lv_bldat    TYPE c LENGTH 15.
    DATA: lv_duedate  TYPE c LENGTH 15.
    DATA: lv_amount   TYPE string.
    DATA: lv_period   TYPE c LENGTH 6.

    CONCATENATE ms_invoice_data-documentdate+0(4) '-'
                ms_invoice_data-documentdate+4(2) '-'
                ms_invoice_data-documentdate+6(2) 'T00:00:00'
       INTO lv_bldat.

    CONCATENATE ms_invoice_data-invoiceduedate+0(4) '-'
                ms_invoice_data-invoiceduedate+4(2) '-'
                ms_invoice_data-invoiceduedate+6(2) 'T00:00:00'
       INTO lv_duedate.

    CONCATENATE ms_invoice_data-documentdate+0(4)
                ms_invoice_data-documentdate+4(2)
       INTO lv_period.

    lv_amount = ms_invoice_data-invoiceamount.
    CONDENSE lv_amount.

    CONCATENATE
    '{'
        '"Header": {'
            '"AppKey": “' ms_service_info-additional_field3 '”'
            '"Channel": "' ms_service_info-additional_field4 '",'
            '"ChannelSessionId": "' mv_session_id '",'
            '"ChannelRequestId": "' mv_request_id '"'
        '},'
        '"Parameters": ['
            '{'
                '"AssociationCode": "' ms_service_info-additional_field1 '",'
                '"SubscriberNumber": "' ms_subscribe-subscriber_number '",'
                '"InvoiceNumber": "' ms_invoice_data-invoicenumber '",'
                '"InvoiceCurrencyCode": "' ms_invoice_data-transactioncurrency '",'
                '"PaymentCurrencyCode": "' ms_invoice_data-transactioncurrency '",'
                '"InvoiceDate": "' lv_bldat '",'
                '"InvoiceAmount": ' lv_amount ','
                '"LastPaymentDate": "' lv_duedate '",'
                '"DelayedLastPaymentDate": "' lv_duedate '",'
                '"ParametricCode": " ",'
                '"Explanation": " ",'
                '"OperationType": "U",'
                '"MaturityType": "V",'
                '"DebitCreditType": "B",'
                '"SubscriberName": "' '",'
                '"SubscriberSurname": "' '",'
                '"PeriodCode": "' lv_period '",'
                '"InvoiceIncludedBlockage": " ",'
                '"CustomerNo": ' ms_invoice_data-customer ''
            '}'
        ']'
    '}'
    INTO rv_request.
  ENDMETHOD.