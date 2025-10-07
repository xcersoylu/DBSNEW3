  METHOD response_mapping_collect_inv.
    TYPES : BEGIN OF ty_satir,
              aboneno     TYPE string,
              faturano    TYPE string,
              fattutar    TYPE string,
              doviz       TYPE string,
              sonodmtarih TYPE string,
              odmtarih    type string,
              odntutarytl TYPE string,
              odntutarusd TYPE string,
              refno       TYPE string,
              statu       TYPE string,
              bilgi1      type string,
              bilgi2      type string,
            END OF ty_satir,
            tt_Satir type table of ty_satir with default key.
    DATA lt_xml_response TYPE tt_satir.
    DATA(lv_response) = iv_response.
    REPLACE ALL OCCURRENCES OF '&lt;' IN lv_response WITH '<'.
    REPLACE ALL OCCURRENCES OF '&gt;' IN lv_response WITH '>'.
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = lv_response ).
    READ TABLE lt_xml INTO DATA(ls_error_code) WITH KEY node_type = mc_value_node name = 'pErrCode'.
    READ TABLE lt_xml INTO DATA(ls_error_text) WITH KEY node_type = mc_value_node name = 'pErrText'.
    IF ls_error_code-value = '0'. "başarılı
      LOOP AT lt_xml INTO DATA(ls_xml_line) WHERE name = 'SATIR'
                                              AND node_type = 'CO_NT_ELEMENT_OPEN'.
        DATA(lv_index) = sy-tabix + 1.
        APPEND INITIAL LINE TO lt_xml_response ASSIGNING FIELD-SYMBOL(<ls_response_line>).
        LOOP AT lt_xml INTO DATA(ls_xml_line2) FROM lv_index.
          IF ( ls_xml_line2-name = 'SATIR' AND ls_xml_line2-node_type = 'CO_NT_ELEMENT_CLOSE' ).
            EXIT.
          ENDIF.
          CHECK ls_xml_line2-node_type = 'CO_NT_VALUE'.
          CASE ls_xml_line2-name.
            WHEN 'AboneNo' OR 'FaturaNo' OR 'FatTutar' OR 'Doviz' OR 'SonOdmTarih' OR 'OdmTarih' OR
                 'OdnTutarYTL' OR 'OdnTutarUSD' OR 'RefNo' OR 'Statu' OR 'Bilgi1' OR 'Bilgi2'.
              TRANSLATE ls_xml_line2-name TO UPPER CASE.
              ASSIGN COMPONENT ls_xml_line2-name OF STRUCTURE <ls_response_line> TO FIELD-SYMBOL(<lv_value>).
              CHECK sy-subrc = 0.
              <lv_value> = ls_xml_line2-value.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.
      READ TABLE lt_xml_response INTO DATA(ls_xml_response) WITH KEY faturano = ms_invoice_data-invoicenumber.
      SHIFT ls_xml_response-fattutar    LEFT DELETING LEADING '0'.
      SHIFT ls_xml_response-odntutarytl LEFT DELETING LEADING '0'.
      IF ls_xml_response-odntutarytl IS NOT INITIAL AND ls_xml_response-odntutarytl GT 0.
        es_collect_detail-payment_amount = ls_xml_response-odntutarytl.
        es_collect_detail-payment_currency = 'TRY'.
      ELSE.
        es_collect_detail-payment_amount = ls_xml_response-fattutar.
        es_collect_detail-payment_currency = ls_xml_response-doviz.
      ENDIF.
      CONCATENATE ls_xml_response-odmtarih(4)
                  ls_xml_response-odmtarih+5(2)
                  ls_xml_response-odmtarih+8(2) INTO es_collect_detail-payment_date.
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_error number = 014 ) TO rt_messages.
      adding_error_message(
        EXPORTING
          iv_message  = ls_error_text-value
        CHANGING
          ct_messages = rt_messages
      ).
    ENDIF.
  ENDMETHOD.