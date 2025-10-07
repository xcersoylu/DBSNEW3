  METHOD prepare_delete_invoice.
    DATA(ls_log) = get_log(  ).
    mv_http_method = 'DELETE'.
    CONCATENATE '{ "invoice_id": "' ls_log-invoice_id '" }' INTO rv_request.
    mv_url = ms_service_info-cpi_url2.
    mv_methodname = 'invoice'.
  ENDMETHOD.