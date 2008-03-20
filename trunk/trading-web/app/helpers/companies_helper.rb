module CompaniesHelper
  include AjaxScaffold::Helper
  def num_columns
    scaffold_columns.length + 1 
  end
  
  def scaffold_columns
    Company.scaffold_columns
  end
  
  def extract_tab_class tab_name
    tab = params[:tab]
    tab ||= 'overview'
    if tab == tab_name
      'active'
    else
      ''
    end
  end
  
  def tab_content
    params[:tab] || 'overview'
  end
  
  def build_table_for_income_statement
    build_table_for @company.statements.income_statements unless @table
  end
  
  def build_table_for statements
    historical_statements = HistoricalStatements.new(statements)
    @table = historical_statements.historical_statement_table.sort
    historical_statements
  end
  
  def load_company_and_build_statement_table unit_of_time=nil
    load_company
    statement_type = StatementType.find params[:type]
    historical_statements = build_table_for @company.statements.send(statement_type.method_like_name)
    @table = historical_statements.convert_table_to(unit_of_time).sort unless unit_of_time.nil?
    statement_type
  end
end
