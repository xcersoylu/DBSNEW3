  METHOD if_http_service_extension~handle_request.
    DATA lt_messages TYPE ydbs_tt_bapiret2.
    DATA lo_fi_doc TYPE REF TO ycl_dbs_create_financial_doc.
    DATA lt_log TYPE TABLE OF ydbs_t_log.
    DATA lt_all_log TYPE ydbs_t_all_log_tab.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    LOOP AT ms_request-invoicedata INTO DATA(ls_invoice_data) WHERE invoicestatus <> mc_ready.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      APPEND VALUE #( id = 'YDBS_MC' type = mc_error number = 008 ) TO ms_response-messages.
    ELSE.
      SELECT * FROM ydbs_t_bnk_dtype INTO TABLE @DATA(lt_bank_doctype).
      LOOP AT ms_request-invoicedata INTO DATA(ls_request).
        DATA(lo_bank) = ycl_dbs_bank=>factory( iv_bankinternalid = ls_request-bankinternalid
                                                iv_companycode    = ls_request-companycode
                                                iv_customer       = ls_request-customer
                                                iv_invoice_data   = ls_request ).
        lo_bank->call_api( EXPORTING iv_api_type = mc_send IMPORTING et_messages = lt_messages ).
        IF lt_messages IS NOT INITIAL.
          APPEND LINES OF lt_messages TO ms_response-messages.
        ENDIF.
        IF NOT line_exists( lt_messages[ type = mc_error ] ). "hata yoksa FI belgesi yarat.
          lo_fi_doc = NEW #( is_invoice_data = ls_request
                             is_bank_doctype = VALUE #( lt_bank_doctype[ companycode = ls_request-companycode bankinternalid = ls_request-bankinternalid ] OPTIONAL ) ).
          lo_fi_doc->create_temporary_fi_doc(
            IMPORTING
              ev_accountingdocument = DATA(lv_temp_doc)
              ev_fiscalyear         = DATA(lv_temp_year)
              et_messages           = DATA(lt_temp_messages)
          ).
          IF lt_temp_messages IS NOT INITIAL.
            APPEND LINES OF lt_temp_messages TO ms_response-messages.
          ENDIF.
          IF line_exists( lt_temp_messages[ type = mc_error ] ).
            APPEND VALUE #( id = 'YDBS_MC' type = mc_error number = 006 ) TO ms_response-messages.
          ELSE.
            lo_fi_doc->create_clearing_doc(
              IMPORTING
                ev_accountingdocument = DATA(lv_clearing_doc)
                ev_fiscalyear         = DATA(lv_clearing_year)
                et_messages           = DATA(lt_clearing_messages)
            ).
            IF lt_clearing_messages IS NOT INITIAL.
              APPEND LINES OF lt_clearing_messages TO ms_response-messages.
            ENDIF.
          ENDIF.
*log kayıt
          APPEND VALUE #( companycode             = ls_request-companycode
                          accountingdocument      = ls_request-accountingdocument
                          fiscalyear              = ls_request-fiscalyear
                          accountingdocumentitem  = ls_request-accountingdocumentitem
                          invoicenumber           = ls_request-invoicenumber
                          invoiceduedate          = ls_request-invoiceduedate
                          invoiceamount           = ls_request-invoiceamount
                          transactioncurrency     = ls_request-transactioncurrency
                          invoicestatus           = 'S'
                          bankinternalid          = ls_request-bankinternalid
                          temporary_document      = lv_temp_doc
                          temporary_document_year = lv_temp_year
                          clearing_document       = lv_clearing_doc
                          clearing_document_year  = lv_clearing_year
                          batch_id                = lo_bank->mv_batch_id
                          trf_id                  = lo_bank->mv_trf_id
                          invoice_id              = lo_bank->mv_invoice_id ) TO lt_log.

**log kayıt
*          APPEND VALUE #( log_id                  = ls_request-log_id
*                          companycode             = ls_request-companycode
*                          accountingdocument      = ls_request-accountingdocument
*                          fiscalyear              = ls_request-fiscalyear
*                          accountingdocumentitem  = ls_request-accountingdocumentitem
*                          invoicenumber           = ls_request-invoicenumber
*                          invoiceduedate          = ls_request-invoiceduedate
*                          invoiceamount           = ls_request-invoiceamount
*                          transactioncurrency     = ls_request-transactioncurrency
*                          invoicestatus           = 'S'
*                          bankinternalid          = ls_request-bankinternalid
*                          temporary_document      = lv_temp_doc
*                          temporary_document_year = lv_temp_year
*                          clearing_document       = lv_clearing_doc
*                          clearing_document_year  = lv_clearing_year
*                          batch_id                = lo_bank->mv_batch_id
*                          trf_id                  = lo_bank->mv_trf_id
*                          timestamp               = ycl_dbs_common=>get_local_time(  )-timestamp
*                          createdby               = sy-uname                       ) TO lt_all_log.

        ENDIF.
*clear
        FREE: lo_bank , lo_fi_doc.
        CLEAR: lo_bank , lo_fi_doc , lv_temp_doc , lv_temp_year , lt_temp_messages ,
               lv_clearing_doc , lv_clearing_year , lt_clearing_messages , lt_messages .
      ENDLOOP.
      IF lt_log IS NOT INITIAL.
        MODIFY ydbs_t_log FROM TABLE @lt_log.
      ENDIF.
*      IF lt_all_log IS NOT INITIAL.
*        ycl_dbs_common=>save_dbs_log(
*          EXPORTING
*            it_log    = lt_all_log
*        ).
*      ENDIF.
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