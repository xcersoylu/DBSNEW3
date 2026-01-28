  METHOD response_mapping_limit.
*    DATA ls_limit TYPE ydbs_t_limit.
*    DATA(ls_time_info) = ycl_dbs_common=>get_local_time(  ).
*    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).
*    READ TABLE lt_xml INTO DATA(ls_error_code) WITH KEY node_type = mc_value_node name = 'ResultCode'.
*    READ TABLE lt_xml INTO DATA(ls_error_text) WITH KEY node_type = mc_value_node name = 'ResultMessage'.
*    IF ls_error_code-value = '300'.
*      ls_limit = VALUE #( companycode    = ms_service_info-companycode
*                          bankinternalid = ms_service_info-bankinternalid
*                          customer       = ms_subscribe-customer
*                          currency       = ms_service_info-currency
*                          limit_timestamp = ls_time_info-timestamp
*                          limit_date      = ls_time_info-date
*                          limit_time      = ls_time_info-time
*                          total_limit     = VALUE #( lt_xml[ node_type = mc_value_node name = 'FutureInvoiceAmount' ]-value OPTIONAL )
*                          available_limit = VALUE #( lt_xml[ node_type = mc_value_node name = 'AvailableLimit' ]-value OPTIONAL )
*                          risk            = VALUE #( lt_xml[ node_type = mc_value_node name = 'DdaLimit' ]-value OPTIONAL ) ).
*      MODIFY ydbs_t_limit FROM @ls_limit.
*      APPEND VALUE #( id = mc_id type = mc_success number = 021 message_v1 = ms_subscribe-customer
*                                                                message_v2 = ms_service_info-companycode  ) TO rt_messages.
*    ELSE.
*      adding_error_message(
*        EXPORTING
*          iv_message  = ls_error_text-value
*        CHANGING
*          ct_messages = rt_messages
*      ).
*    ENDIF.

    TYPES: BEGIN OF ty_dbslimitinfo,
             type                TYPE string,
             resultcode          TYPE string,
             resultmessage       TYPE string,
             associationcode     TYPE string,
             subscribernumber    TYPE string,
             ddalimit            TYPE string,
             ddarisk             TYPE string,
             availablelimit      TYPE string,
             futureinvoiceamount TYPE string,
             accountbranchcode   TYPE string,
             accountnumber       TYPE string,
             accountsuffix       TYPE string,
             subscribername      TYPE string,
             accountbalance      TYPE string,
             blockageamount      TYPE string,
             availablebalance    TYPE string,
           END OF ty_dbslimitinfo.

    TYPES: ty_dbslimitinfo_tab TYPE STANDARD TABLE OF ty_dbslimitinfo WITH EMPTY KEY.

    TYPES: BEGIN OF ty_data,
             type                      TYPE string,
             invoicesincluded          TYPE string,
             associationcode           TYPE string,
             subscribernumber          TYPE string,
             dbslimitresult            TYPE ty_dbslimitinfo_tab,
             customerno                TYPE string,
             querydate                 TYPE string,
             enddate                   TYPE string,
             consolide                 TYPE string,
             customerpersonelaccountno TYPE string,
             shareaccountnumber        TYPE string,
             mainbranchcode            TYPE string,
           END OF ty_data.

    TYPES: BEGIN OF ty_root,
             type TYPE string,
             data TYPE ty_data,
           END OF ty_root.
    DATA ls_json TYPE ty_root.
    DATA ls_limit TYPE ydbs_t_limit.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = iv_response
      CHANGING
        data             = ls_json
    ).
    READ TABLE ls_json-data-dbslimitresult INTO DATA(ls_result) WITH KEY resultcode = '300'.
    IF sy-subrc = 0.
      LOOP AT ls_json-data-dbslimitresult INTO ls_result WHERE subscribernumber IS NOT INITIAL.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        DATA(ls_time_info) = ycl_dbs_common=>get_local_time(  ).
        ls_limit = VALUE #( companycode    = ms_service_info-companycode
                            bankinternalid = ms_service_info-bankinternalid
                            customer       = ms_subscribe-customer
                            currency       = ms_service_info-currency
                            limit_timestamp = ls_time_info-timestamp
                            limit_date      = ls_time_info-date
                            limit_time      = ls_time_info-time
                            total_limit     = ls_result-ddalimit
                            available_limit = ls_result-availablelimit - ls_result-futureinvoiceamount "ls_result-availablelimit
                            risk            = ls_result-ddarisk ).
        MODIFY ydbs_t_limit FROM @ls_limit.
        APPEND VALUE #( id = mc_id type = mc_success number = 021 message_v1 = ms_subscribe-customer
                                                                  message_v2 = ms_service_info-companycode  ) TO rt_messages.
*limit tarihçeli tutulsun denmişti sonradan son 2 güne düşürdük.
        DATA lv_yesterday TYPE d.
        lv_yesterday = ls_time_info-date - 1.
        DELETE FROM ydbs_t_limit WHERE companycode    = @ms_service_info-companycode
                                   AND bankinternalid = @ms_service_info-bankinternalid
                                   AND customer       = @ms_subscribe-customer
                                   AND currency       = @ms_service_info-currency
                                   AND limit_date     < @lv_yesterday.
      ENDIF.
    ELSE.
      LOOP AT ls_json-data-dbslimitresult INTO ls_result WHERE resultcode IS NOT INITIAL AND resultcode <> '300'.
        EXIT.
      ENDLOOP.
      IF ls_result-resultmessage IS NOT INITIAL.
        adding_error_message(
          EXPORTING
            iv_message  = ls_result-resultmessage
          CHANGING
            ct_messages = rt_messages
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.