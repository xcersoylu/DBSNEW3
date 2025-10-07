  METHOD response_mapping_limit.
    TYPES : BEGIN OF ty_xml,
              subscribercode TYPE string,
              subscribername TYPE string,
              currencycode   TYPE string,
              totallimit     TYPE string,
              usedlimit      TYPE string,
              availablelimit TYPE string,
              unexpiredrisk  TYPE string,
            END OF ty_xml.
    DATA lt_xml_response TYPE TABLE OF ty_xml.
    DATA lv_subscribercode TYPE string.
    DATA ls_limit TYPE ydbs_t_limit.
    DATA(ls_time_info) = ycl_dbs_common=>get_local_time(  ).
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).

    LOOP AT lt_xml INTO DATA(ls_xml_line) WHERE name = 'subcriberList'
                                            AND node_type = 'CO_NT_ELEMENT_OPEN'.
      DATA(lv_index) = sy-tabix + 1.
      APPEND INITIAL LINE TO lt_xml_response ASSIGNING FIELD-SYMBOL(<ls_response_line>).
      LOOP AT lt_xml INTO DATA(ls_xml_line2) FROM lv_index.
        IF ( ls_xml_line2-name = 'subcriberList' AND ls_xml_line2-node_type = 'CO_NT_ELEMENT_CLOSE' ).
          EXIT.
        ENDIF.
        CHECK ls_xml_line2-node_type = 'CO_NT_VALUE'.
        TRANSLATE ls_xml_line2-name TO UPPER CASE.
        ASSIGN COMPONENT ls_xml_line2-name OF STRUCTURE <ls_response_line> TO FIELD-SYMBOL(<lv_value>).
        CHECK sy-subrc = 0.
        <lv_value> = ls_xml_line2-value.
        IF ls_xml_line2-name = 'SUBSCRIBERCODE'.
          CONDENSE <lv_value> NO-GAPS.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    lv_subscribercode = ms_subscribe-subscriber_number.
    CONDENSE lv_subscribercode.
    ls_limit = VALUE #( companycode    = ms_service_info-companycode
                        bankinternalid = ms_service_info-bankinternalid
                        customer       = ms_subscribe-customer
                        currency       = ms_service_info-currency
                        limit_timestamp = ls_time_info-timestamp
                        limit_date      = ls_time_info-date
                        limit_time      = ls_time_info-time
                        total_limit     = VALUE #( lt_xml_response[ subscribercode = lv_subscribercode ]-totallimit OPTIONAL )
                        available_limit = VALUE #( lt_xml_response[ subscribercode = lv_subscribercode ]-availablelimit OPTIONAL )
                        risk            = VALUE #( lt_xml_response[ subscribercode = lv_subscribercode ]-unexpiredrisk OPTIONAL ) ).
    MODIFY ydbs_t_limit FROM @ls_limit.
    APPEND VALUE #( id = mc_id type = mc_success number = 021 message_v1 = ms_subscribe-customer
                                                          message_v2 = ms_service_info-companycode  ) TO rt_messages.
  ENDMETHOD.