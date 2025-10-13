  METHOD response_mapping_update_inv.
    TYPES: BEGIN OF ty_amount,
             currency_code  TYPE string,
             equivalent_cry TYPE string,
             equivalent_qty TYPE string,
             quantity       TYPE string,
           END OF ty_amount.

    TYPES: BEGIN OF ty_invoice,
             invoice_id                  TYPE string,
             invoice_number              TYPE string,
             corporate_code              TYPE string,
             subscriber_code             TYPE string,
             due_date                    TYPE string,
             due_amount                  TYPE ty_amount,
             is_factoring                TYPE string,
             gib_invoice_type            TYPE string,
             serial_number               TYPE string,
             sequence_number             TYPE string,
             original_amount             TYPE ty_amount,
             taxless_amount              TYPE ty_amount,
             requested_payment_curr_code TYPE string,
             description                 TYPE string,
             external_reference          TYPE string,
             hash_code                   TYPE string,
             invoice_release_date        TYPE string,
           END OF ty_invoice.

    TYPES: BEGIN OF ty_root,
             data TYPE ty_invoice,
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
    DATA lv_response TYPE string.
    lv_response = iv_response.
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
      REPLACE 'requested_payment_currency_code' IN lv_response WITH 'requested_payment_curr_code'.
      /ui2/cl_json=>deserialize(
        EXPORTING
          json             = lv_response
        CHANGING
          data             = ls_json_success
      ).
      APPEND VALUE #( id = mc_id type = mc_success number = 022 ) TO rt_messages.
    ENDIF.

  ENDMETHOD.