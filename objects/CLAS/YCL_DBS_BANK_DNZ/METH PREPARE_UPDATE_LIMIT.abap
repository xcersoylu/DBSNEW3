  METHOD prepare_update_limit.
    DATA lv_date TYPE string.

*    CONCATENATE ms_invoice_data-documentdate+4(2)
*                ms_invoice_data-documentdate(4)
*           INTO lv_date.
    data(ls_local_time) = ycl_dbs_common=>get_local_time(  ).
    lv_date = |{ ls_local_time-date+4(2) }{ ls_local_time-date(4) }|.
    mv_session_id = get_session_id(  ).
    mv_request_id = get_request_id(  ).
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
                '"InvoicesIncluded": "' lv_date '",'
                '"CustomerNo": ' ms_service_info-additional_field2 ''
            '}'
        ']'
    '}'
    INTO rv_request.
  ENDMETHOD.