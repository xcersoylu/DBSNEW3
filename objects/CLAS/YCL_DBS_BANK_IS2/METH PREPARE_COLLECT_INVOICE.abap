  METHOD prepare_collect_invoice.
    mv_corporate_code = ms_service_info-additional_field1.
    mv_subscriber_code = ms_subscribe-subscriber_number.
  ENDMETHOD.