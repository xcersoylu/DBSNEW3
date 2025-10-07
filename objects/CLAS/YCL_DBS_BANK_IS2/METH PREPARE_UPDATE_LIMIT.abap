  METHOD prepare_update_limit.
    mv_corporate_code = ms_service_info-additional_field1.
    mv_subscriber_code = ms_subscribe-subscriber_number.
    mv_page_size = ms_service_info-additional_field2.
    mv_page_index = ms_service_info-additional_field3.
  ENDMETHOD.