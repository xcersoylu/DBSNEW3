managed implementation in class zbp_dbs_ddl_i_log_update unique;
strict ( 2 );

define behavior for YDBS_DDL_I_LOG_UPDATE //alias <alias_name>
persistent table ydbs_t_log
lock master
authorization master ( instance )
//etag master <field_name>
{
  create ( authorization : global );
  update;
  delete;
  field ( readonly ) Companycode, Accountingdocument, Fiscalyear, Accountingdocumentitem;
  mapping for ydbs_t_log
  {
  Companycode = companycode;
  Accountingdocument = accountingdocument;
  Accountingdocumentitem = accountingdocumentitem;
  Fiscalyear = fiscalyear;
//  Invoiceduedate = invoiceduedate;
  Invoicestatus = invoicestatus;
  CollectDocument = collect_document;
  CollectDocumentYear = collect_document_year;
  ClearingDocument = clearing_document;
  ClearingDocumentYear = clearing_document_year;
  TemporaryDocument = temporary_document;
  TemporaryDocumentYear = temporary_document_year;
  }
}