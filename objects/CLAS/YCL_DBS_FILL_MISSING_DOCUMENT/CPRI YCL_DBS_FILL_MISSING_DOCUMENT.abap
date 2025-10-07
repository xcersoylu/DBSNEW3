  PRIVATE SECTION.
    DATA: ms_request  TYPE ydbs_s_fill_missing_doc_req,
          ms_response TYPE ydbs_s_fill_missing_doc_res.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json',
               mc_error          TYPE symsgty VALUE 'E',
               mc_success        TYPE symsgty VALUE 'S'.