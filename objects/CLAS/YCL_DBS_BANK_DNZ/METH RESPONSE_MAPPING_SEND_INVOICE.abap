  METHOD response_mapping_send_invoice.
*    DATA(lt_xml) = ycl_dbs_common=>parse_xml( EXPORTING iv_xml_string  = iv_response ).
*    READ TABLE lt_xml INTO DATA(ls_error_code) WITH KEY node_type = mc_value_node name = 'ErrorCode'.
*    READ TABLE lt_xml INTO DATA(ls_error_text) WITH KEY node_type = mc_value_node name = 'ErrorMessage'.
*    IF ls_error_code-value = '000'. "başarılı
*      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
*    ELSE.
*      APPEND VALUE #( id = mc_id type = mc_error number = 004 ) TO rt_messages.
*      adding_error_message(
*        EXPORTING
*          iv_message  = ls_error_text-value
*        CHANGING
*          ct_messages = rt_messages
*      ).
*    ENDIF.
    TYPES: BEGIN OF ty_data,
             type                     TYPE string,
             errorcode                TYPE string,
             errormessage             TYPE string,
             refbranchcode            TYPE string,
             refnumber                TYPE string,
             refdate                  TYPE string,
             tranid                   TYPE string,
             explanation              TYPE string,
             state                    TYPE string,
             confirmationtoken        TYPE string,
             requiredconfirmationtype TYPE string,
             mobilephonenumbe         TYPE string,
             isrequestsourceapi       TYPE string,
             npssurveyguid            TYPE string,
           END OF ty_data.
    TYPES: BEGIN OF ty_root,
             type TYPE string,
             data TYPE ty_data,
           END OF ty_root.
    DATA ls_json TYPE ty_root.
    DATA ls_limit TYPE ydbs_t_limit.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = iv_response
      CHANGING
        data             = ls_json
    ).
    IF ls_json-data-errorcode = '000'. "başarılı
      APPEND VALUE #( id = mc_id type = mc_success number = 003 ) TO rt_messages.
    ELSE.
      APPEND VALUE #( id = mc_id type = mc_error number = 004 ) TO rt_messages.
      adding_error_message(
        EXPORTING
          iv_message  = ls_json-data-errormessage
        CHANGING
          ct_messages = rt_messages
      ).
    ENDIF.
  ENDMETHOD.