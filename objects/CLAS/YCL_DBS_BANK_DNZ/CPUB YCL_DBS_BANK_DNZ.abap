CLASS ycl_dbs_bank_dnz DEFINITION
  PUBLIC
  INHERITING FROM ycl_dbs_bank
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA mv_session_id TYPE string.
    DATA mv_request_id TYPE string.
    METHODS: prepare_update_limit REDEFINITION,
      prepare_send_invoice REDEFINITION,
      prepare_delete_invoice REDEFINITION,
      prepare_update_invoice REDEFINITION,
      prepare_collect_invoice REDEFINITION,
      response_mapping_limit REDEFINITION,
      response_mapping_send_invoice REDEFINITION,
      response_mapping_update_inv REDEFINITION,
      response_mapping_delete_inv REDEFINITION,
      response_mapping_collect_inv REDEFINITION.