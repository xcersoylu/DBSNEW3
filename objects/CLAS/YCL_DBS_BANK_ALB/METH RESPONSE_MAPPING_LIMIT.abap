  METHOD response_mapping_limit.
    DATA ls_limit TYPE ydbs_t_limit.
    DATA(ls_time_info) = ycl_dbs_common=>get_local_time(  ).
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).
    LOOP AT lt_xml ASSIGNING FIELD-SYMBOL(<ls_xml>) WHERE node_type = mc_value_node AND name = 'CdaBalance'.
      REPLACE ',' IN <ls_xml>-value WITH '.'.
    ENDLOOP.
    ls_limit = VALUE #( companycode    = ms_service_info-companycode
                        bankinternalid = ms_service_info-bankinternalid
                        customer       = ms_subscribe-customer
                        currency       = ms_service_info-currency
                        limit_timestamp = ls_time_info-timestamp
                        limit_date      = ls_time_info-date
                        limit_time      = ls_time_info-time
                        total_limit     = VALUE #( lt_xml[ node_type = mc_value_node name = 'Limit' ]-value OPTIONAL )
                        available_limit = VALUE #( lt_xml[ node_type = mc_value_node name = 'AvailableLimit' ]-value OPTIONAL )
                        risk            = VALUE #( lt_xml[ node_type = mc_value_node name = 'CdaBalance' ]-value OPTIONAL )
                        maturity_invoice_count = VALUE #( lt_xml[ node_type = mc_value_node name = 'MaturityInvoiceCount' ]-value OPTIONAL )
                        maturity_amount = VALUE #( lt_xml[ node_type = mc_value_node name = 'MaturityAmount' ]-value OPTIONAL )
                        ).
    MODIFY ydbs_t_limit FROM @ls_limit.
    APPEND VALUE #( id = mc_id type = mc_success number = 021 message_v1 = ms_subscribe-customer
                                                          message_v2 = ms_service_info-companycode  ) TO rt_messages.
  ENDMETHOD.