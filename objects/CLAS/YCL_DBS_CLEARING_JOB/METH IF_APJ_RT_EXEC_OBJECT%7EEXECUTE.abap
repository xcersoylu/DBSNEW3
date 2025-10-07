  METHOD if_apj_rt_exec_object~execute.

    TYPES : BEGIN OF ty_ccode_range,
              sign   TYPE c LENGTH 1,
              option TYPE c LENGTH 2,
              low    TYPE bukrs,
              high   TYPE bukrs,
            END OF ty_ccode_range,
            BEGIN OF ty_bankk_range,
              sign   TYPE c LENGTH 1,
              option TYPE c LENGTH 2,
              low    TYPE bankk,
              high   TYPE bankk,
            END OF ty_bankk_range,
            BEGIN OF ty_duedate_range,
              sign   TYPE c LENGTH 1,
              option TYPE c LENGTH 2,
              low    TYPE datum,
              high   TYPE datum,
            END OF ty_duedate_range,
            tt_ccode_range   TYPE TABLE OF ty_ccode_range WITH EMPTY KEY,
            tt_bankk_range   TYPE TABLE OF ty_bankk_range WITH EMPTY KEY,
            tt_duedate_range TYPE TABLE OF ty_duedate_range WITH EMPTY KEY.
    DATA lr_ccode TYPE tt_ccode_range.
    DATA lr_bankk TYPE tt_bankk_range.
    DATA lr_duedate TYPE tt_duedate_range.
    DATA lt_messages TYPE ydbs_tt_bapiret2.
    DATA lt_send_documents TYPE ydbs_tt_invoice_cockpit_data.
    DATA lo_fi_doc TYPE REF TO ycl_dbs_create_financial_doc.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_CCODE'.
          APPEND VALUE #( sign = ls_parameter-sign
                          option = ls_parameter-option
                          low = ls_parameter-low
                          high = ls_parameter-high ) TO lr_ccode.
        WHEN 'S_BANKK'.
          APPEND VALUE #( sign = ls_parameter-sign
                          option = ls_parameter-option
                          low = ls_parameter-low
                          high = ls_parameter-high ) TO lr_bankk.
        WHEN 'S_DUEDAT'.
          IF ls_parameter-low IS INITIAL AND ls_parameter-high IS INITIAL.
            APPEND VALUE #( sign = ls_parameter-sign
                            option = 'EQ'
                            low = ycl_dbs_common=>get_local_time(  )-date ) TO lr_duedate.
          ELSE.
            APPEND VALUE #( sign = ls_parameter-sign
                            option = ls_parameter-option
                            low = ls_parameter-low
                            high = ls_parameter-high ) TO lr_duedate.
          ENDIF.
      ENDCASE.
    ENDLOOP.
*bankaya yüklenmiş ya da güncellenmiş faturalar tahsil edilmiş olabilir o yüzden o statü deki faturalar okunuyor
    SELECT *
      FROM ydbs_t_log
     WHERE companycode IN @lr_ccode
       AND bankinternalid IN @lr_bankk
       AND invoiceduedate IN @lr_duedate
       AND invoicestatus IN ( @mc_send,@mc_updated )
     INTO TABLE @DATA(lt_send).
    IF sy-subrc = 0.

      SELECT bkpf~companycode,
             bkpf~accountingdocument,
             bkpf~fiscalyear,
             bseg~accountingdocumentitem,
             bseg~customer,
             customer~organizationbpname1 AS customername,
             customer~organizationbpname2 AS customersurname,
             subscriber~bankinternalid,
             send~invoicenumber,
             customer~taxnumber1,
             customer~taxnumber2,
             subscriber~subscriber_number AS subscribernumber,
             bseg~accountingdocumenttype,
             bseg~documentdate,
             bseg~postingdate,
             bseg~duecalculationbasedate,
             bseg~cashdiscount1days,
             send~invoiceduedate,
             bseg~absoluteamountintransaccrcy,
             bseg~transactioncurrency,
             send~invoiceamount,
             bkpf~documentreferenceid,
             bseg~paymentmethod,
             bseg~paymentblockingreason,
             bseg~reference1idbybusinesspartner,
             bseg~reference2idbybusinesspartner,
             bseg~reference3idbybusinesspartner,
             bseg~assignmentreference,
             bseg~originalreferencedocument,
             bseg~documentitemtext,
             send~invoicestatus,
             send~collect_document,
             send~collect_document_year,
             send~clearing_document,
             send~clearing_document_year,
             send~temporary_document,
             send~temporary_document_year
       FROM @lt_send AS send INNER JOIN i_journalentry            AS bkpf ON bkpf~companycode = send~companycode
                                                                         AND bkpf~accountingdocument = send~accountingdocument
                                                                         AND bkpf~fiscalyear = send~fiscalyear
                             INNER JOIN i_operationalacctgdocitem AS bseg ON bseg~companycode        = send~companycode
                                                                         AND bseg~accountingdocument = send~accountingdocument
                                                                         AND bseg~fiscalyear         = send~fiscalyear
                                                                         AND bseg~accountingdocumentitem = send~accountingdocumentitem
                             INNER JOIN i_customer AS customer ON customer~customer = bseg~customer
                             INNER JOIN ydbs_t_subsmap AS subscriber ON subscriber~companycode = send~companycode
                                                                    AND subscriber~bankinternalid = send~bankinternalid
                                                                    AND subscriber~customer = customer~customer
              INTO CORRESPONDING FIELDS OF TABLE @lt_send_documents.
      IF sy-subrc = 0.
        SORT lt_send_documents BY companycode accountingdocument fiscalyear accountingdocumentitem bankinternalid.
        DELETE ADJACENT DUPLICATES FROM lt_send_documents COMPARING companycode accountingdocument fiscalyear accountingdocumentitem bankinternalid.
        SELECT * FROM ydbs_t_bnk_dtype INTO TABLE @DATA(lt_bank_doctype).

        TRY.
            DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object = 'YDBS_APP_LOG'
                                                                                           subobject = 'YDBS_CLEARING_LOG' ) ).
          CATCH cx_bali_runtime.
        ENDTRY.


        LOOP AT lt_send_documents INTO DATA(ls_invoice).

          DATA(lo_bank) = ycl_dbs_bank=>factory( iv_bankinternalid = ls_invoice-bankinternalid
                                                 iv_companycode    = ls_invoice-companycode
                                                 iv_customer       = ls_invoice-customer
                                                 iv_invoice_data   = ls_invoice  ).
          lo_bank->call_api( EXPORTING iv_api_type = mc_collect IMPORTING et_messages = lt_messages ).
          IF lt_messages IS NOT INITIAL.
            LOOP AT lt_messages INTO DATA(ls_message).
              DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                                 id = ls_message-id
                                                                 number = ls_message-number
                                                                 variable_1 =  ls_message-message_v1
                                                                 variable_2 =  ls_message-message_v2
                                                                 variable_3 =  ls_message-message_v3
                                                                 variable_4 =  ls_message-message_v4 ).
              TRY.
                  lo_log->add_item( lo_message ).
                CATCH cx_bali_runtime.
              ENDTRY.
            ENDLOOP.
          ENDIF.

          IF NOT line_exists( lt_messages[ type = mc_error ] ). "hata yoksa FI belgesi yarat.
            lo_fi_doc = NEW #( is_invoice_data = ls_invoice
                               is_collect_detail = lo_bank->ms_collect_detail
                               is_bank_doctype = VALUE #( lt_bank_doctype[ companycode = ls_invoice-companycode bankinternalid = ls_invoice-bankinternalid ] OPTIONAL ) ).
            lo_fi_doc->create_collect_fi_doc(
              IMPORTING
                ev_accountingdocument = DATA(lv_collect_doc)
                ev_fiscalyear         = DATA(lv_collect_year)
                et_messages           = DATA(lt_collect_messages)
            ).
            IF lt_collect_messages IS NOT INITIAL.
              LOOP AT lt_collect_messages INTO ls_message.
                lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                                   id = ls_message-id
                                                                   number = ls_message-number
                                                                   variable_1 =  ls_message-message_v1
                                                                   variable_2 =  ls_message-message_v2
                                                                   variable_3 =  ls_message-message_v3
                                                                   variable_4 =  ls_message-message_v4 ).
                TRY.
                    lo_log->add_item( lo_message ).
                  CATCH cx_bali_runtime.
                ENDTRY.
              ENDLOOP.
            ENDIF.
          ENDIF.
          IF lv_collect_doc IS NOT INITIAL.
            UPDATE ydbs_t_log
               SET invoicenumber           = @ls_invoice-invoicenumber,
                   invoiceduedate          = @ls_invoice-invoiceduedate,
                   invoiceamount           = @ls_invoice-invoiceamount,
                   transactioncurrency     = @ls_invoice-transactioncurrency,
                   invoicestatus           = 'C',
                   collect_document        = @lv_collect_doc,
                   collect_document_year   = @lv_collect_year
             WHERE companycode             = @ls_invoice-companycode
               AND accountingdocument      = @ls_invoice-accountingdocument
               AND fiscalyear              = @ls_invoice-fiscalyear
               AND accountingdocumentitem  = @ls_invoice-accountingdocumentitem.
          ENDIF.
          FREE: lo_bank , lo_fi_doc.
          CLEAR: lo_bank , lo_fi_doc , lv_collect_doc , lv_collect_year , lt_collect_messages , lt_messages .
        ENDLOOP.
      ELSE.
        lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                           id = 'YDBS_MC'
                                                           number = 001 ).
        TRY.
            lo_log->add_item( lo_message ).
          CATCH cx_bali_runtime.
        ENDTRY.
      ENDIF.
    ELSE.
      lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                         id = 'YDBS_MC'
                                                         number = 001 ).
      TRY.
          lo_log->add_item( lo_message ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.

  ENDMETHOD.