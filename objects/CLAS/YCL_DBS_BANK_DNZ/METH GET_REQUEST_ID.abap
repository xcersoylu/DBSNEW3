  METHOD get_request_id.
    ycl_dbs_common=>generate_random(
      EXPORTING
        iv_randomset = '0123456789'
        iv_length    = 19
      RECEIVING
        rv_string    = rv_request_id
    ).
  ENDMETHOD.