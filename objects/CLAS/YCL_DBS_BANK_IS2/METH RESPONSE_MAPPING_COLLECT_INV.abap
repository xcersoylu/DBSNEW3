  METHOD response_mapping_collect_inv.
    TYPES: BEGIN OF ty_amount,
             currency_code  TYPE string,
             equivalent_cry TYPE string,
             equivalent_qty TYPE string,
             quantity       TYPE string,
           END OF ty_amount.

    TYPES: BEGIN OF ty_invoice_result,
             invoice_id           TYPE string,
             corporate_code       TYPE string,
             subscriber_code      TYPE string,
             invoice_number       TYPE string,
             due_date             TYPE string,
             due_amount           TYPE ty_amount,
             status               TYPE string,
             invoice_type         TYPE string,
             payment_type         TYPE string,
             invoice_release_date TYPE string,
             creation_date        TYPE string,
             invoice_amount       TYPE ty_amount,
           END OF ty_invoice_result.

    TYPES: ty_invoice_result_tab TYPE STANDARD TABLE OF ty_invoice_result WITH EMPTY KEY.

    TYPES: BEGIN OF ty_search_result,
             search_invoice_result TYPE ty_invoice_result_tab,
             total_count           TYPE string,
           END OF ty_search_result.

    TYPES: BEGIN OF ty_root,
             data TYPE ty_search_result,
           END OF ty_root.

    TYPES: BEGIN OF ty_error,
             code    TYPE string,
             message TYPE string,
           END OF ty_error.

    TYPES: tt_error TYPE STANDARD TABLE OF ty_error WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_root2,
             errors TYPE tt_error,
           END OF ty_root2.
    DATA ls_json_success TYPE ty_root.
    DATA ls_json_error TYPE ty_root2.
    IF iv_response CS '"errors:"'.
      /ui2/cl_json=>deserialize(
        EXPORTING
          json             = iv_response
        CHANGING
          data             = ls_json_error
      ).
      DATA(ls_error) = VALUE #( ls_json_error-errors[ 1 ] OPTIONAL ).
      adding_error_message(
        EXPORTING
          iv_message  = ls_error-message
        CHANGING
          ct_messages = rt_messages
      ).
    ELSE.
      /ui2/cl_json=>deserialize(
        EXPORTING
          json             = iv_response
        CHANGING
          data             = ls_json_success
      ).
      DATA(ls_result) =  VALUE #( ls_json_success-data-search_invoice_result[ invoice_number = ms_invoice_data-invoicenumber ] OPTIONAL ).
      IF ls_result-status =  'Paid'.
        es_collect_detail = VALUE #( payment_amount = ls_result-invoice_amount-quantity
                                     payment_date = |{ ls_result-due_date(4) }{ ls_result-due_date+5(2) }{ ls_result-due_date+8(2) }|
                                     payment_currency = ms_invoice_data-transactioncurrency ).
      ELSE.
        APPEND VALUE #( id = mc_id type = mc_error number = 020 message_v1 = ls_result-status  ) TO rt_messages.
      ENDIF.
    ENDIF.
  ENDMETHOD.