  METHOD response_mapping_collect_inv.

    TYPES: BEGIN OF ty_fatura,
             faturadandusulecektutar TYPE string,
             tahsilatdovizkuru       TYPE string,
             anafirmakurumtanimid    TYPE string,
             faturadurum             TYPE string,
             tahsilattarihi          TYPE string,
             tahsilatdovizcinsi      TYPE string,
             kalantutar              TYPE string,
             sistemegeristarihi      TYPE string,
             kurumadi                TYPE string,
             anafirmadakibayikodu    TYPE string,
             faturano                TYPE string,
             sonodemetarihi          TYPE string,
             faturatutari            TYPE string,
             dovizcinsi              TYPE string,
             faturacikistarihi       TYPE string,
             adsoyad                 TYPE string,
             dbsfaturadurumdetaykodu TYPE string,
             odenentutar             TYPE string,
             garantilitungar         TYPE string,
             garantisiztutar         TYPE string,
             pesinvadelidurumu       TYPE string,
             mahsuptutar             TYPE string,
             bolgekodu               TYPE string,
             referansalan6           TYPE string,
             referansalan7           TYPE string,
             referansalan8           TYPE string,
             referansalan9           TYPE string,
             referansalan10          TYPE string,
             aciklama                TYPE string,
             transactionobjectid     TYPE string,
             garantilitungarorjinal  TYPE string,
             garantisiztutarorjinal  TYPE string,
           END OF ty_fatura,
           tt_fatura TYPE TABLE OF ty_fatura WITH DEFAULT KEY.
    DATA lt_xml_response TYPE tt_fatura.
    DATA lv_date TYPE string.
    DATA lv_time TYPE string.
    DATA lv_year TYPE c LENGTH 4.
    DATA lv_month TYPE c LENGTH 2.
    DATA lv_day TYPE c LENGTH 2.
    DATA(lv_response) = iv_response.
    REPLACE ALL OCCURRENCES OF '&lt;' IN lv_response WITH '<'.
    REPLACE ALL OCCURRENCES OF '&gt;' IN lv_response WITH '>'.
    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = lv_response ).
    READ TABLE lt_xml INTO DATA(ls_error_code) WITH KEY node_type = mc_value_node name = 'BaseIslemKodu'.
    READ TABLE lt_xml INTO DATA(ls_error_text) WITH KEY node_type = mc_value_node name = 'BaseUrunMesaj'.
    IF ls_error_code-value = '01'. "başarılı

      LOOP AT lt_xml INTO DATA(ls_xml_line) WHERE name = 'DTOFatura'
                                              AND node_type = 'CO_NT_ELEMENT_OPEN'.
        DATA(lv_index) = sy-tabix + 1.
        APPEND INITIAL LINE TO lt_xml_response ASSIGNING FIELD-SYMBOL(<ls_response_line>).
        LOOP AT lt_xml INTO DATA(ls_xml_line2) FROM lv_index.
          IF ( ls_xml_line2-name = 'DTOFatura' AND ls_xml_line2-node_type = 'CO_NT_ELEMENT_CLOSE' ).
            EXIT.
          ENDIF.
          CHECK ls_xml_line2-node_type = 'CO_NT_VALUE'.
          CASE ls_xml_line2-name.
            WHEN 'FaturadanDusulecekTutar' OR
                  'TahsilatDovizKuru' OR
                 'AnaFirmaKurumTanimId' OR
                 'FaturaDurum' OR
                 'TahsilatTarihi' OR
                 'TahsilatDovizCinsi' OR
                 'KalanTutar' OR
                 'SistemeGirisTarihi' OR
                 'KurumAdi' OR
                 'AnaFirmadakiBayiKodu' OR
                 'FaturaNo' OR
                 'SonOdemeTarihi' OR
                 'FaturaTutari' OR
                 'DovizCinsi' OR
                 'FaturaCikisTarihi' OR
                 'AdSoyad' OR
                 'DbsFaturaDurumDetayKodu' OR
                 'OdenenTutar' OR
                 'GarantiliTutar' OR
                 'GarantisizTutar' OR
                 'PesinVadeliDurumu' OR
                 'MahsupTutar' OR
                 'BolgeKodu' OR
                 'ReferansAlan6' OR
                 'ReferansAlan7' OR
                 'ReferansAlan8' OR
                 'ReferansAlan9' OR
                 'ReferansAlan10' OR
                 'Aciklama' OR
                 'TransactionObjectId' OR
                 'GarantiliTutarOrjinal' OR
                 'GarantisizTutarOrjinal' .
              TRANSLATE ls_xml_line2-name TO UPPER CASE.
              ASSIGN COMPONENT ls_xml_line2-name OF STRUCTURE <ls_response_line> TO FIELD-SYMBOL(<lv_value>).
              CHECK sy-subrc = 0.
              <lv_value> = ls_xml_line2-value.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.
      READ TABLE lt_xml_response INTO DATA(ls_xml_response) WITH KEY faturano = ms_invoice_data-invoicenumber.
      IF ls_xml_response-faturadurum = 'Odendi'.
        es_collect_detail-payment_amount = ls_xml_response-odenentutar.
        es_collect_detail-payment_currency = ls_xml_response-tahsilatdovizcinsi.
        SPLIT ls_xml_response-tahsilattarihi AT space INTO lv_date lv_time.
        SPLIT lv_date AT '.' INTO lv_day lv_month lv_year.
        es_collect_detail-payment_date = |{ lv_year }{ lv_month ALPHA = IN }{ lv_day ALPHA = IN }|.
      ELSE.
        APPEND VALUE #( id = mc_id type = mc_error number = 020 message_v1 = ls_xml_response-faturadurum  ) TO rt_messages.
      ENDIF.
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