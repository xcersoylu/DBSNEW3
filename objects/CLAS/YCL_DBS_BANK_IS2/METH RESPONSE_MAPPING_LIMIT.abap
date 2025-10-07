  METHOD response_mapping_limit.
    TYPES: BEGIN OF ty_subscriber,
             corporate_code  TYPE string,
             subscriber_code TYPE string,
             subscriber_name TYPE string,
           END OF ty_subscriber.

    TYPES: BEGIN OF ty_limit,
             currency_code  TYPE string,
             equivalent_cry TYPE string,
             equivalent_qty TYPE string,
             quantity       TYPE string,
           END OF ty_limit.

    TYPES: tt_shared_subscriber TYPE STANDARD TABLE OF ty_subscriber WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_search_subscriber_result,
             subscriber                    TYPE ty_subscriber,
             limit_gap                     TYPE ty_limit,
             total_limit                   TYPE ty_limit,
             used_limit                    TYPE ty_limit,
             available_limit               TYPE ty_limit,
             waiting_invoices_total_amount TYPE ty_limit,
             number_of_waiting_invoices    TYPE string,
             nof_waiting_discounted_inv    TYPE string,
             is_shared_limit               TYPE string,
             subscribers_with_shared_limit TYPE tt_shared_subscriber,
           END OF ty_search_subscriber_result.

    TYPES: tt_search_subscriber_result TYPE STANDARD TABLE OF ty_search_subscriber_result WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_data,
             search_subscriber_result TYPE tt_search_subscriber_result,
             total_count              TYPE string,
           END OF ty_data.

    TYPES: BEGIN OF ty_root,
             data TYPE ty_data,
           END OF ty_root.
    DATA ls_json TYPE ty_root.
    DATA lv_response TYPE string.
    DATA ls_limit TYPE ydbs_t_limit.
    lv_response = iv_response.
    REPLACE 'number_of_waiting_discounted_invoices' IN lv_response WITH 'nof_waiting_discounted_inv'.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = lv_response
      CHANGING
        data             = ls_json
    ).
    DATA(ls_time_info) = ycl_dbs_common=>get_local_time(  ).

    LOOP AT ls_json-data-search_subscriber_result INTO DATA(ls_result).
      cl_abap_string_utilities=>del_trailing_blanks( CHANGING str = ls_result-subscriber-subscriber_code ).
      DATA(lv_len) = strlen( ls_result-subscriber-subscriber_code ).
      CHECK ls_result-subscriber-subscriber_code = mv_subscriber_code.
      ls_limit = VALUE #( companycode    = ms_service_info-companycode
                          bankinternalid = ms_service_info-bankinternalid
                          customer       = ms_subscribe-customer
                          currency       = ms_service_info-currency
                          limit_timestamp = ls_time_info-timestamp
                          limit_date      = ls_time_info-date
                          limit_time      = ls_time_info-time
                          total_limit     = ls_result-total_limit-quantity
                          available_limit = ls_result-available_limit-quantity ).
    ENDLOOP.
    IF ls_limit IS NOT INITIAL.
      MODIFY ydbs_t_limit FROM @ls_limit.
      APPEND VALUE #( id = mc_id type = mc_success number = 021 message_v1 = ms_subscribe-customer
                                                          message_v2 = ms_service_info-companycode  ) TO rt_messages.
    ENDIF.

  ENDMETHOD.