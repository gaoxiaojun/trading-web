module PortfoliosHelper
  
  def add_portfolio_withholding_popup
   popup_script = escape_javascript render(:partial => "/portfolios/add_portfolio_withholding")
   popup_script = javascript_tag("var modal_login = initModalWin('portfolio_add_link',\"#{popup_script}\", 'add_symbol');")
    "<div id=\"portfolio_add\"><button class='selected' id='portfolio_add_link'>Add</button></div>" << popup_script
  end
end
