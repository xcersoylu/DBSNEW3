  METHOD response_mapping_collect_inv.
    TYPES : BEGIN OF ty_invoiceresult,
              type                TYPE string,
              resultcode          TYPE string,
              resultmessage       TYPE string,
              invoicenumber       TYPE string,
              subscribernumber    TYPE string,
              invoicedate         TYPE string,
              invoiceamount       TYPE string,
              invoicecurrencycode TYPE string,
              paymentdate         TYPE string,
              paymentamount       TYPE string,
              paymentcurrencycode TYPE string,
              statuscode          TYPE string,
              subscribername      TYPE string,
              lastpaymentdate     TYPE string,
              lastupdatedate      TYPE string,
              recordstatus        TYPE string,
              invoicematurtytype  TYPE string,
              explanation         TYPE string,
            END OF ty_invoiceresult,
            tt_invoiceresult TYPE TABLE OF ty_invoiceresult WITH EMPTY KEY.
    TYPES: BEGIN OF ty_data,
             type                      TYPE string,
             associationcode           TYPE string,
             dbsinvoiceresult          TYPE tt_invoiceresult,
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
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = iv_response
      CHANGING
        data             = ls_json
    ).
    READ TABLE ls_json-data-dbsinvoiceresult INTO DATA(ls_invoiceresult) WITH KEY  resultcode = '000'.
    IF sy-subrc = 0.
      READ TABLE ls_json-data-dbsinvoiceresult INTO ls_invoiceresult WITH KEY invoicenumber = ms_invoice_data-invoicenumber
                                                                              statuscode = 'O'.
      IF sy-subrc = 0.
        es_collect_detail = VALUE #( payment_amount = ls_invoiceresult-paymentamount
                                     payment_date = ls_invoiceresult-paymentdate
                                     payment_currency = ls_invoiceresult-paymentcurrencycode ).
      ELSE.
        READ TABLE ls_json-data-dbsinvoiceresult INTO ls_invoiceresult WITH KEY invoicenumber = ms_invoice_data-invoicenumber.
        APPEND VALUE #( id = mc_id type = mc_error number = 020 message_v1 = ls_invoiceresult-statuscode  ) TO rt_messages.
      ENDIF.
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_error number = 014 ) TO rt_messages.
      LOOP AT ls_json-data-dbsinvoiceresult INTO ls_invoiceresult WHERE resultcode IS NOT INITIAL
                                                                    AND resultcode NE '000'
                                                                    AND resultmessage IS NOT INITIAL.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        adding_error_message(
          EXPORTING
            iv_message  = ls_invoiceresult-resultmessage
          CHANGING
            ct_messages = rt_messages
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.