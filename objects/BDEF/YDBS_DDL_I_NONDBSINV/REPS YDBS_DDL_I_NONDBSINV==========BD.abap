managed implementation in class zbp_dbs_ddl_i_nondbsinv unique;
strict ( 2 );

define behavior for YDBS_DDL_I_NONDBSINV //alias <alias_name>
persistent table ydbs_t_nondbsinv
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Companycode , AccountingDocument , FiscalYear ;
  mapping for ydbs_t_nondbsinv
    {
      CompanyCode = companycode;
      AccountingDocument = accountingdocument;
      FiscalYear = fiscalyear;
    }
}