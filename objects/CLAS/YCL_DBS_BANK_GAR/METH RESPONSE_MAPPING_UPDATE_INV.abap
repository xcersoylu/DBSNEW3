  METHOD response_mapping_update_inv.
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).
    READ TABLE lt_xml INTO DATA(ls_bankstatus) WITH KEY node_type = mc_value_node name = 'TrfStatusCode'.
    IF ls_bankstatus-value = '0000'.
      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
    ELSE.
      adding_error_message(
        EXPORTING
          iv_message  = CONV #( get_error_text( CONV #( ls_bankstatus-value ) ) )
        CHANGING
          ct_messages = rt_messages ).
    ENDIF.
  ENDMETHOD.