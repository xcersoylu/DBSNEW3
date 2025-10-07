  METHOD get_log_id.
    DATA(lv_date) = cl_abap_context_info=>get_system_date(  ).
    SELECT SINGLE log_count FROM ydbs_t_logid WHERE log_date = @lv_date
    INTO @DATA(lv_log_count).
    IF sy-subrc = 0.
      lv_log_count += 1.
      UPDATE ydbs_t_logid
         SET log_count = @lv_log_count
       WHERE log_date = @lv_date.
    ELSE.
      lv_log_count += 1.
      INSERT ydbs_t_logid FROM @( VALUE #( log_date = lv_date log_count = lv_log_count ) ).
    ENDIF.
    rv_log_id = lv_date && lv_log_count.
  ENDMETHOD.