  METHOD save_dbs_log.
    DATA lt_log TYPE TABLE OF ydbs_t_all_log.
    LOOP AT it_log INTO DATA(ls_log).
      IF ls_log-log_id IS INITIAL.
        ls_log-log_id = get_log_id(  ).
        APPEND ls_log TO lt_log.
      ELSE.
        APPEND ls_log TO lt_log.
      ENDIF.
    ENDLOOP.
    IF lt_log IS NOT INITIAL.
      MODIFY ydbs_t_all_log FROM TABLE @lt_log.
    ENDIF.
  ENDMETHOD.