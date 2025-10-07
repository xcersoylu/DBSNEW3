  METHOD response_mapping_send_invoice.

    TYPES: BEGIN OF ty_data,
             invoice_id     TYPE string,
             invoice_number TYPE string,
             message        TYPE string,
           END OF ty_data.

    TYPES: BEGIN OF ty_root,
             data TYPE ty_data,
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
      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
      mv_invoice_id = ls_json_success-data-invoice_id.
    ENDIF.
  ENDMETHOD.