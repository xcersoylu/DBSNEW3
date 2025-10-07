  METHOD response_mapping_send_invoice.
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).
    "2 tane status alanı döndüğü için ilki fatura durumunu gösteren status alanı 2. si servisin sonucunu dönüyor.
    LOOP AT lt_xml INTO DATA(ls_error_code) WHERE node_type = mc_value_node AND name = 'status'.
    ENDLOOP.
    READ TABLE lt_xml INTO DATA(ls_error_text) WITH KEY node_type = mc_value_node name = 'statusMessage'.
    IF ls_error_code-value = '0000'. "başarılı
      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_error number = 004 ) TO rt_messages.
      adding_error_message(
        EXPORTING
          iv_message  = ls_error_text-value
        CHANGING
          ct_messages = rt_messages
      ).
    ENDIF.
  ENDMETHOD.