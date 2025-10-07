  METHOD prepare_send_invoice.
    TYPES: BEGIN OF ty_amount,
             currency_code TYPE string,
             quantity      TYPE string,
           END OF ty_amount.

    TYPES: BEGIN OF ty_invoice,
             corporate_code                 TYPE string,
             subscriber_code                TYPE string,
             invoice_number                 TYPE string,
             due_date                       TYPE string,
             invoice_release_date           TYPE string,
             invoice_amount                 TYPE ty_amount,
             invoice_type                   TYPE string,
             payment_type                   TYPE string,
             requested_payment_curr_code    TYPE string,
             is_factoring                   TYPE string,
             gib_invoice_type               TYPE string,
             serial_number                  TYPE string,
             sequence_number                TYPE string,
             original_amount                TYPE ty_amount,
             hash_code                      TYPE string,
             taxless_amount                 TYPE ty_amount,
             description                    TYPE string,
             external_reference             TYPE string,
             external_detail                TYPE string,
             corporate_specific_rule_detail TYPE string,
           END OF ty_invoice.
    DATA ls_json TYPE ty_invoice.
    DATA lv_due_date TYPE string.
    DATA lv_invoice_date TYPE string.
    CONCATENATE ms_invoice_data-invoiceduedate(4) '-'
                ms_invoice_data-invoiceduedate+4(2) '-'
                ms_invoice_data-invoiceduedate+6(2)
                'T00:00:00' INTO lv_due_date.
    CONCATENATE ms_invoice_data-documentdate(4) '-'
                ms_invoice_data-documentdate+4(2) '-'
                ms_invoice_data-documentdate+6(2)
                'T00:00:00' INTO lv_invoice_date.
    ls_json = VALUE #( corporate_code = ms_service_info-additional_field1
                       subscriber_code = ms_subscribe-subscriber_number
                       invoice_number = ms_invoice_data-invoicenumber
                       due_date       = lv_due_date
                       invoice_release_date = lv_invoice_date
                       invoice_amount = VALUE #( currency_code = ms_invoice_data-transactioncurrency
                                                 quantity = ms_invoice_data-invoiceamount )
                       invoice_type = COND #( WHEN ycl_dbs_common=>get_local_time( )-date = ms_invoice_data-invoiceduedate
                                              THEN 'Advance' ELSE 'Term' )
                       payment_type = 'Collection' ).
    rv_request = /ui2/cl_json=>serialize( EXPORTING data = ls_json pretty_name = 'L' ).
    mv_url = ms_service_info-cpi_url2.
    mv_methodname = 'invoice'.
  ENDMETHOD.