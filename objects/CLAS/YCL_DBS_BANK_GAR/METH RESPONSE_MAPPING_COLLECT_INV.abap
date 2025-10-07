  METHOD response_mapping_collect_inv.
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).
    READ TABLE lt_xml INTO DATA(ls_bankstatus) WITH KEY node_type = mc_value_node name = 'StatusCode'.
    IF ls_bankstatus-value = '0700' OR ls_bankstatus-value = '0701'.
      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
      READ TABLE lt_xml INTO DATA(ls_amount) WITH KEY node_type = mc_value_node name = 'PaymentAmount'.
      READ TABLE lt_xml INTO DATA(ls_date) WITH KEY node_type = mc_value_node name = 'OdemeTarihi'.
      es_collect_detail = VALUE #( payment_amount = ls_amount-value
                                   payment_date = ms_invoice_data-invoiceduedate
                                   payment_currency = ms_invoice_data-transactioncurrency ).
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_success number = 014 ) TO rt_messages.
      adding_error_message(
        EXPORTING
          iv_message  = CONV #( get_error_text( CONV #( ls_bankstatus-value ) ) )
        CHANGING
          ct_messages = rt_messages
      ).
    ENDIF.
  ENDMETHOD.