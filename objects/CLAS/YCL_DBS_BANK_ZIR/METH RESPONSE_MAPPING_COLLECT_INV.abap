  METHOD response_mapping_collect_inv.
    TYPES : BEGIN OF ty_xml,
              cevapkodu               TYPE string,
              cevapmesaji             TYPE string,
              dbsno                   TYPE string,
              faturano                TYPE string,
              sonodemetarihi          TYPE string,
              faturatutari            TYPE string,
              faturadovizkodu         TYPE string,
              tahsilattarihi          type string,
              tahsilattutari          TYPE string,
              tahsilatdovizkodu       TYPE string,
              hesabakonanbloketutari  TYPE string,
              krediyekonanbloketutari TYPE string,
              kayitdurumu             TYPE string,
              kayitzaman              TYPE string,
              iptalzaman              TYPE string,
            END OF ty_xml.
    DATA lt_xml_response TYPE TABLE OF ty_xml.
    DATA lv_day          TYPE c LENGTH 2.
    DATA lv_month        TYPE c LENGTH 2.
    DATA lv_year         TYPE c LENGTH 4.
    DATA lv_payment_date TYPE d.
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).

    LOOP AT lt_xml INTO DATA(ls_xml_line) WHERE name = 'FaturaSorguCevap'
                                            AND node_type = 'CO_NT_ELEMENT_OPEN'.
      DATA(lv_index) = sy-tabix + 1.
      APPEND INITIAL LINE TO lt_xml_response ASSIGNING FIELD-SYMBOL(<ls_response_line>).
      LOOP AT lt_xml INTO DATA(ls_xml_line2) FROM lv_index.
        IF ( ls_xml_line2-name = 'FaturaSorguCevap' AND ls_xml_line2-node_type = 'CO_NT_ELEMENT_CLOSE' ).
          EXIT.
        ENDIF.
        CHECK ls_xml_line2-node_type = 'CO_NT_VALUE'.
        TRANSLATE ls_xml_line2-name TO UPPER CASE.
        ASSIGN COMPONENT ls_xml_line2-name OF STRUCTURE <ls_response_line> TO FIELD-SYMBOL(<lv_value>).
        CHECK sy-subrc = 0.
        <lv_value> = ls_xml_line2-value.
      ENDLOOP.
    ENDLOOP.

    READ TABLE lt_xml_response INTO DATA(ls_xml_response) WITH KEY faturano = ms_invoice_data-invoicenumber
                                                                   kayitdurumu = 'A'.
    IF ls_xml_response-cevapkodu = '0'. "başarılı
      es_collect_detail = VALUE #( payment_amount = ls_xml_response-faturatutari
                                   payment_date = ls_xml_response-tahsilattarihi+6(4) && ls_xml_response-tahsilattarihi+2(2) && ls_xml_response-tahsilattarihi(2)
                                   payment_currency = COND #(  WHEN ls_xml_response-faturadovizkodu = '1' THEN 'USD'
                                                               WHEN ls_xml_response-faturadovizkodu = '2' THEN 'EUR'
                                                               WHEN ls_xml_response-faturadovizkodu = '88' THEN 'TRY'
                                                               ) ).
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_error number = 014 ) TO rt_messages.
      adding_error_message(
        EXPORTING
          iv_message  = ls_xml_response-cevapmesaji
        CHANGING
          ct_messages = rt_messages
      ).
    ENDIF.
  ENDMETHOD.