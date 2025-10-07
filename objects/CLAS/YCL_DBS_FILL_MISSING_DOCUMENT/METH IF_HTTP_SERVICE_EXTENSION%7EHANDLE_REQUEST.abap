  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    DATA lt_send_documents TYPE ydbs_tt_invoice_cockpit_data.
    DATA ls_update TYPE ydbs_t_log.
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).

    SELECT SINGLE * FROM ydbs_t_log WHERE companycode = @ms_request-companycode
                                      AND accountingdocument = @ms_request-accountingdocument
                                      AND fiscalyear = @ms_request-fiscalyear
                                      AND accountingdocumentitem = @ms_request-accountingdocumentitem
    INTO @DATA(ls_log).
    IF sy-subrc = 0.
      IF ms_request-temporary_document IS INITIAL.
        ls_update-temporary_document = ls_log-temporary_document.
        ls_update-temporary_document_year = ls_log-temporary_document_year.
      ELSE.
*        IF ls_log-temporary_document IS INITIAL.
          ls_update-temporary_document = ms_request-temporary_document.
          ls_update-temporary_document_year = ms_request-temporary_document_year.
*        ELSE.
*          APPEND VALUE #( id = 'YDBS_MC' type = mc_error number = 015 ) TO ms_response-messages.
*        ENDIF.
      ENDIF.

      IF ms_request-clearing_document IS INITIAL.
        ls_update-clearing_document = ls_log-clearing_document.
        ls_update-clearing_document_year = ls_log-clearing_document_year.
      ELSE.
*        IF ls_log-clearing_document IS INITIAL.
          ls_update-clearing_document = ms_request-clearing_document.
          ls_update-clearing_document_year = ms_request-clearing_document_year.
*        ELSE.
*          APPEND VALUE #( id = 'YDBS_MC' type = mc_error number = 016 ) TO ms_response-messages.
*        ENDIF.
      ENDIF.

      IF ms_request-collect_document IS INITIAL.
        ls_update-collect_document = ls_log-collect_document.
        ls_update-collect_document_year = ls_log-collect_document_year.
      ELSE.
*        IF ls_log-collect_document IS INITIAL.
          ls_update-collect_document = ms_request-collect_document.
          ls_update-collect_document_year = ms_request-collect_document_year.
*        ELSE.
*          APPEND VALUE #( id = 'YDBS_MC' type = mc_error number = 017 ) TO ms_response-messages.
*        ENDIF.
      ENDIF.
*      IF ms_response-messages IS INITIAL.
        UPDATE ydbs_t_log
           SET temporary_document = @ls_update-temporary_document,
               temporary_document_year = @ls_update-temporary_document_year,
               clearing_document = @ls_update-clearing_document,
               clearing_document_year = @ls_update-clearing_document_year,
               collect_document = @ls_update-collect_document,
               collect_document_year = @ls_update-collect_document_year
         WHERE companycode = @ms_request-companycode
           AND accountingdocument = @ms_request-accountingdocument
           AND fiscalyear = @ms_request-fiscalyear
           AND accountingdocumentitem = @ms_request-accountingdocumentitem.
        IF sy-subrc = 0.
          APPEND VALUE #( id = 'YDBS_MC' type = mc_success number = 019 ) TO ms_response-messages.
        ENDIF.
*      ENDIF.

    ELSE.
      APPEND VALUE #( id = 'YDBS_MC' type = mc_error number = 018 ) TO ms_response-messages.
    ENDIF.
    IF ms_response-messages IS NOT INITIAL.
      LOOP AT ms_response-messages ASSIGNING FIELD-SYMBOL(<ls_message>).
        MESSAGE ID <ls_message>-id
                TYPE <ls_message>-type
                NUMBER <ls_message>-number
                WITH <ls_message>-message_v1
                     <ls_message>-message_v2
                     <ls_message>-message_v3
                     <ls_message>-message_v4
               INTO <ls_message>-message.
      ENDLOOP.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).

  ENDMETHOD.