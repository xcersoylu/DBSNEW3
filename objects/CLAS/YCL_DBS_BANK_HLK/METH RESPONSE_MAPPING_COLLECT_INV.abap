  METHOD response_mapping_collect_inv.
    TYPES : BEGIN OF ty_result,
              aciklama       TYPE string,
              banka_kayit_no TYPE string,
              durum_kodu     TYPE string,
              fatura_no      TYPE string,
              fatura_tarihi  TYPE string,
              fatura_tutari  TYPE wrbtr,
              musteri_dbs_no TYPE string,
              odeme_tarihi   TYPE string,
              odeme_tutari   TYPE string,
              para_birimi    TYPE waers,
              vade_tarihi    TYPE string,
            END OF ty_result,
            tt_result TYPE TABLE OF ty_result WITH DEFAULT KEY,
            BEGIN OF ty_response,
              dbs_fatura_sorgularesult TYPE tt_result,
            END OF ty_response,
            BEGIN OF ty_error,
              errorcode    TYPE string,
              errormessage TYPE string,
            END OF ty_error,
            BEGIN OF ty_json,
              errordetails          TYPE ty_error,
              faturasorgularesponse TYPE ty_response,
              faturaiptalresponse   TYPE string,
              faturayukleresponse   TYPE string,
              limitsorgularesponse  TYPE string,
            END OF ty_json.
    DATA ls_json TYPE ty_json.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = iv_response
      CHANGING
        data             = ls_json
    ).
    IF ls_json-errordetails-errorcode IS INITIAL.
      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
        READ TABLE ls_json-faturasorgularesponse-dbs_fatura_sorgularesult INTO data(ls_Response) WITH KEY fatura_no = ms_invoice_data-invoicenumber
                                                                                                         durum_kodu = 'O'."24.01.2024: O-Ödendi, S-Ödenecek
      es_collect_detail = VALUE #( payment_amount = ls_response-odeme_tutari
                                   payment_date = ls_response-odeme_tarihi
                                   payment_currency = ls_response-para_birimi ).
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_error number = 014 ) TO rt_messages.
      adding_error_message(
        EXPORTING
          iv_message  = ls_json-errordetails-errormessage
        CHANGING
          ct_messages = rt_messages
      ).
    ENDIF.
  ENDMETHOD.