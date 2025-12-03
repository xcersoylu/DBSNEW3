  METHOD prepare_collect_invoice.
    DATA lv_querydate TYPE string.
    DATA lv_enddate type string.
    CONCATENATE ms_invoice_data-querydate+0(4) '-'
                ms_invoice_data-querydate+4(2) '-'
                ms_invoice_data-querydate+6(2) 'T00:00:00'
       INTO lv_querydate.
    CONCATENATE ms_invoice_data-querydate+0(4) '-'
                ms_invoice_data-querydate+4(2) '-'
                ms_invoice_data-querydate+6(2) 'T23:59:59'
       INTO lv_enddate.
    mv_session_id = get_session_id(  ).
    mv_request_id = get_request_id(  ).
    mv_url = ms_service_info-cpi_url3.
    CONCATENATE
    '{'
        '"Header": {'
            '"AppKey": "' ms_service_info-additional_field3 '",'
            '"Channel": "' ms_service_info-additional_field4 '",'
            '"ChannelSessionId": "' mv_session_id '",'
            '"ChannelRequestId": "' mv_request_id '"'
        '},'
        '"Parameters": ['
            '{'
                '"AssociationCode": "' ms_service_info-additional_field1 '",'
                '"QueryDate": "' lv_querydate '",'
                '"EndDate": "' lv_enddate '",'
                '"CustomerNo": "' ms_service_info-additional_field2 '"'
            '}'
        ']'
    '}'
    INTO rv_request.
  ENDMETHOD.