var DEFAULT_SEARCHBOX_VALUE = "type filter terms...";
var ACTIVE_CLASS_NAME = "active";
var LOADING_CLASS_NAME = "loading";
var ELEMENT_NODE_TYPE = 1;
var SELECTED_CLASS_NAME = "selected";
var statement_type = 1;
var removed_columns_by_type = $H({1:[],2:[],3:[]});
var selectedColumns = 0;
var currentPosition = 1;
var scrollLock = 0;
var NUMBER_OF_VISIBLE_COLUMNS=2;
var currentColumn = 0;
var columnNumber = 0;
var GRAPH_SUMMURY_ACC_BY_STAT_TYPE = $H({1:[0],2:[1],3:[0]});
var disableStatementTableScript = false;
var annualized = false;
var SECTOR_HOVER = 'Filters companies by sector: ';
var STOCK_HOVER = 'More company info for: ';
var DATE_HOVER = 'Filters companies by last traded date as of: ';

function addTypeId(name){
    return name+statement_type;
}
Object.extend(Array.prototype, {
  remove: function(value) {
    delete this[this.indexOf(value)];
  }
});

function partialName(name, partialLength){
    if(!name)
        return;
    if(!partialLength)
       partialLength = 15;
    var span = document.createElement("a");
    if(name.length>partialLength){
       span.innerHTML = name.substring(0,partialLength-8)+"...";
    }else{
       span.innerHTML =  name;
    }
    var m = new Control.Modal(span,{contents: name, hover: true,
             position: 'relative', 
             offsetLeft: 0,
             offsetTop: -31,
             containerClassName: 'hover_modal_container'});
    return span;
}

function control_modal_hover(element_id, contents){
    new Control.Modal(element_id,{
        hover: true,
        position: 'relative',
        offsetLeft: 60,
        containerClassName: 'hover_modal_container',
        contents: function(){return contents;}});
}
function activate_tab(selected_tab_id, element_to_update_id){
 remove_focus();
  if(!selected_tab_id || !element_to_update_id)
    return;
  var selected_tab = $(selected_tab_id);
  Selector.findChildElements(selected_tab.up(1), ['a']).each( function(current_tab){
       if(current_tab.nodeType == ELEMENT_NODE_TYPE){
	       var classNames = current_tab.classNames();
	       if(selected_tab == current_tab){
	           classNames.remove(LOADING_CLASS_NAME);
	           classNames.add(ACTIVE_CLASS_NAME);
	       }else{
	           classNames.remove(ACTIVE_CLASS_NAME);
	           classNames.remove(LOADING_CLASS_NAME);
	       }
	   }
  });
}

function remove_focus(){
    $('search_term').select();
}
function select_tab(activated_tab_id){
    annualized = false;
    if($(activated_tab_id).hasClassName(ACTIVE_CLASS_NAME))
        return false;
    $(activated_tab_id).addClassName(LOADING_CLASS_NAME);
    remove_focus();
}

var justToggled = false;
function onSelectElement(e){
    if(disableStatementTableScript)
        return;
    if(justToggled){
      justToggled = false;
      return;  
    }
    if(e.hasClassName(SELECTED_CLASS_NAME)){
        e.removeClassName(SELECTED_CLASS_NAME);
        selectedColumns=selectedColumns-1;
    }else{
        e.addClassName(SELECTED_CLASS_NAME);
        selectedColumns=selectedColumns+1;
    }
    selectFilterButton();
}
function empty(){}
function showSwitch(rowId){
   if(disableStatementTableScript)
        return;
   var row = $(rowId);
   var span = row.down('td',0).down('span',0);
   var nextRow = row.next("tr");
   if(!nextRow || row.readAttribute('value') == nextRow.readAttribute('value')){
     span.onclick = empty;
     return;
   }
   span.addClassName('account');
}

function hideSwitch(rowId){
  if(disableStatementTableScript)
        return;
   $(rowId).down('td',0).down('span',0).removeClassName('account');
}

function toggleChildRows(span){
   if(disableStatementTableScript)
        return;
  justToggled = true;
  var tr = span.up("tr");
  if(!span.hasClassName('account_sitchoff')){
    span.addClassName('account_sitchoff');
    tr.addClassName('toggled');
    toggleRows(tr, true);
  }else {
    span.removeClassName('account_sitchoff');
    toggleRows(tr, false);
    tr.removeClassName('toggled');
  }
}

function toggleRows(row, hide){
   var nextRow = row.next("tr");
   while(nextRow && (row.readAttribute('value') < nextRow.readAttribute('value'))){
     hide ? nextRow.hide() : new Effect.Appear(nextRow);
     if(nextRow.hasClassName('toggled'))
        break;
     nextRow = nextRow.next("tr");
   }
}

function hideColumn(row_date){
  if(disableStatementTableScript)
        return;
 switchColumn(row_date, true);
}

function restoreColumn(row_date, column){
 switchColumn(row_date, false, column);
}

function switchColumn(row_date, hide, column, added){
  var table = $('statementTable'+statement_type);
  var headers = Selector.findChildElements(table.down('thead').down('tr'), ['th']);
  var col_index = 0;
  var deleted_col_parent = $('deleted_columns_parent');
  var deleted_col = $('deleted_columns');
  for(var size = headers.length; col_index < size; col_index++){
    var header = headers[col_index];
    if(row_date == header.id){
      if(hide){
        if(added){
          header.hide();
        }else{
          new Effect.Fade(header);
          if(deleted_col_parent) {
              new Effect.Highlight(deleted_col_parent);
              removed_columns_by_type.get(statement_type).push(row_date);
          }
        }
        if(deleted_col){
           new Insertion.Bottom(deleted_col, "<a href='#' onclick=\"restoreColumn('"+row_date+"', this);return false;\" id='deleted_col_"+row_date+"' >&nbsp;|&nbsp;"+row_date+"&nbsp;|&nbsp;</a>"); 
        }
      }else{
        new Effect.Appear(row_date);
        if(deleted_col_parent) {
            removed_columns_by_type.get(statement_type).remove(row_date);
        }
      }
      break;  
    }
  }
  Selector.findChildElements(table.down('tbody'),['tr']).each(function(row){
     var cell_index = 0;
     var cells =  Selector.findChildElements(row, ['td']);
     cells.each(function(cell){
        if(cell_index++ == col_index){
          hide ? (added ? cell.hide() : new Effect.Fade(cell)) : new Effect.Appear(cell);
        }
     });
  });
  
  if(column) {
    Element.remove(column);
    new Effect.Highlight($('deleted_columns_parent'));
  }
}

function scrollToNextCol(){
  if(currentColumn > 0) return;
  currentColumn+=NUMBER_OF_VISIBLE_COLUMNS;
  initializeTableCol(currentColumn);
}

function scrollToPrevCol(){
  if(currentColumn < 0) return;
  currentColumn-=NUMBER_OF_VISIBLE_COLUMNS;
  initializeTableCol(currentColumn);
}

function disableScrollButtons(columnNumber, currentCol){
  if(currentCol < 0){
    $('right-enabled').src = '/images/right-enabled.gif';
  }else{
    $('right-enabled').src = '/images/right-disabled.gif';
  }
  
  if((columnNumber + currentCol) > 2){
    $('left-enabled').src = '/images/left-enabled.gif';
  }else{
    $('left-enabled').src = '/images/left-disabled.gif';
  }
}

function initializeTableCol(currentCol){
  var initCol = false;
  if(currentCol== null){
    currentCol = 0;
    initCol = true;
  }
  var table = $('statementTable'+statement_type);
  var headers = Selector.findChildElements(table.down('thead').down('tr'), ['th']);
  disableScrollButtons(headers.length-1, currentCol);
  moveColumns(headers, currentCol, initCol, true);
  var rows = Selector.findChildElements(table.down('tbody'),['tr']);
  for(var i=0, size=rows.length; i<size; ++i){
    moveColumns(Selector.findChildElements(rows[i], ['td']), currentCol, initCol);
  }
}

function moveColumns(cells, currentCol, initCol, header){
    var col_index = 0;
    for(var j=1,size=cells.length;j<size;j++){
        var cell = cells[j];
        var index = currentCol+col_index++;
        if(NUMBER_OF_VISIBLE_COLUMNS> index && index>=0){
            initCol?cell.show():new Effect.Appear(cell);
            if(header){
              var removedCol = $('deleted_col_'+cell.id);
              if(removedCol){
                removed_columns_by_type.get(statement_type).remove(cell.id);
                Element.remove(removedCol);
              }
            }
        }else{
            initCol?cell.hide():new Effect.Fade(cell);
        }
    } 
    return col_index;
}

function initializeStatement(type){
    statement_type = type;
    currentColumn = 0;
    $('deleted_columns').innerHTML = "";
    initializeTableCol();
    removed_columns_by_type.get(type).each(function(column){
       switchColumn(column, true, null, true);
    });
    var search_box = $('search_statement');
    if(search_box.value != "" && search_box.value != DEFAULT_SEARCHBOX_VALUE){
        filter(search_box, search_box.value);
    }
}

function clearSearchBox(searchBox){
    if(searchBox.hasClassName("selected")) return;
    searchBox.value = "";
    searchBox.addClassName("selected");
    $('fiter_button').addClassName("selected");
}

function initSearchBox(searchBox){
    if(searchBox.value != "") return;
    searchBox.value = DEFAULT_SEARCHBOX_VALUE;
    searchBox.removeClassName("selected");
    changeButtonFilter();
}

function resetFilter(){
    var searchBox = $('search_statement');
    searchBox.value = "";
    filter(searchBox, "");
    initSearchBox(searchBox);
}

function changeButtonClear(){
    var filter_button = $('fiter_button');
    filter_button.addClassName("selected");
    filter_button.innerHTML="Clear";
    filter_button.onclick = resetFilter;
}

function changeButtonFilter(isSelected){
    var filter_button=$('fiter_button');
    filter_button.innerHTML="Filter";
    filter_button.onclick = buttonFilter;
    if(isSelected){
        if(!filter_button.hasClassName('selected')){
            filter_button.addClassName("selected");
        }
    }else{
      selectFilterButton();
    }
}

function buttonFilter(){
    filter();
    changeButtonClear();
}

function selectFilterButton(){
    var filter_button=$('fiter_button');
    if(filter_button.innerHTML=="Clear")
        return;
    if(selectedColumns > 0)
        filter_button.addClassName("selected");
    else
        filter_button.removeClassName("selected");
}

function filter(element , value){
    if(value)
        changeButtonClear();
    else
        changeButtonFilter(true);
    $('filter_indicator').removeClassName('no_display');
    if(value) 
        value = value.toLowerCase();
    var table = $('statementTable'+ statement_type);
    var rows = Selector.findChildElements(table.down('tbody'),['tr']);
    var level = 1000;
    rows.each(function(row){
     if(row.hasClassName(SELECTED_CLASS_NAME))
        return;
     var currentLevel = row.readAttribute('value');
     if(currentLevel > level)
        return;
     else
        level = 1000;
     if(row.hasClassName('toggled'))
        level = currentLevel;
     var acc_cell = row.down('td', 0);
     if(acc_cell.innerHTML.toLowerCase().indexOf(value)==-1)
       row.hide();
     else 
       row.show();
    });
    
    window.setTimeout('$(\'filter_indicator\').addClassName(\'no_display\')',250);
}

function initScroll(){
  statement_type = 1;
  currentPosition = 1;
  scrollLock = 0;
}

function initScrollWith(element_id){
    initScroll();
     var tabs = Selector.findChildElements($(element_id).down('div').down('ul'), ['li']);
    for(var i=0, size=tabs.length;i<size;i++){
        if(tabs[i].down('a').hasClassName(ACTIVE_CLASS_NAME)){
            currentPosition = i+1;
            break;
        }
    }
}

function incrementLock(){
  scrollLock++;  
}

function decrementLock(){
  scrollLock--;  
}

function scroll(position){
  if(position == currentPosition || scrollLock>0)
      return;
  var frame = $('ajax-carousel');
  var lis = Selector.findChildElements(frame, ['li']);
  var size = getElementSize(lis[0]);
  var delta = currentPosition - position;
  currentPosition = position;
  lis.each(function(li){
     new Effect.MoveBy(li, 0, delta*size ,{duration:'0.5', beforeStart: incrementLock, afterFinish: decrementLock});
  });
}

function getElementSize(e){
	return e.getDimensions().width + parseFloat(e.getStyle("margin-left")) + parseFloat(e.getStyle("margin-right"));
}

// Anim effects before and after scrolling
function animHandler(status) {
  var region = $('ajax-carousel').down(".carousel-clip-region");
  if (status == "before") {
    new Insertion.Top('ajax-carousel', "<div id='overlay54' class='overlay'><img src='/images/indicator.gif'/>Loading...</div>");
    Effect.Fade(region, {to: 0.3, queue: { position:'end', scope: "ajax-carousel" }, duration: 0.2});
  }
  if (status == "after") {
    Element.remove($('overlay54'));
    Effect.Fade(region, {to: 1, queue: { position:'end', scope: "ajax-carousel" }, duration: 0.2});
  }
}

// Show/hide "loading" overlay before and after ajax request
function ajaxHandler(status) {
  var overlay = $('overlay');
  if(status == "before"){
    if(overlay){
      overlay.setOpacity(0);
      overlay.show();
      Effect.Fade(overlay, {from: 0, to: 0.8, duration: 0.7});
    }else{
      new Insertion.Top("statement-chart", "<div id='overlay' ><img src='/images/indicator.gif'/>Loading...</div>");
    }
  }else{
    Effect.Fade(overlay, {from: 0.8, to: 0.0, duration: 0.9});
  }
}

function overlays(status, elementIds){
  elementIds.each(function(currentId){
    var overlay = $('overlay'+currentId);
    if(status == "before"){
        if(overlay){
            overlay.setOpacity(0);
            overlay.show();
            Effect.Fade(overlay, {from: 0, to: 0.8, duration: 0.7});
        }else{
            new Insertion.Top(currentId, "<div id='overlay"+currentId+"' class='overlay'><img src='/images/indicator.gif'/>Loading...</div>");
        }
    }else{
        Effect.Fade(overlay, {from: 0.8, to: 0.0, duration: 0.9});
    }
  });
}

var layoutExpended = false;
var boxFaded = false;
var LEFT_LAYOUT_OFFSET = 750;
function removeLeftLayout(){
    if(layoutExpended || boxFaded)
       return;
    layoutExpended = true;
    Element.addClassName($('main-context'),'expanded_panel');
    new Effect.MoveBy($('left_panel'), -LEFT_LAYOUT_OFFSET, 0,{duration:'0.4', afterFinish:function(){boxFaded=true;}});
}

function showLeftLayout(){
   if(!(layoutExpended && boxFaded))
       return;
    layoutExpended = false;
    var left_panel = $('left_panel');
    if(layoutExpended) return;
    new Effect.MoveBy(left_panel, LEFT_LAYOUT_OFFSET, 0,{duration:'0.4', afterFinish:shrinkMainLayout});
}

function shrinkMainLayout(){
    if(layoutExpended) return;
    Element.removeClassName($('main-context'),'expanded_panel');
    boxFaded = false;
}

function delHover(span){
    if(disableStatementTableScript)return;
    var del_img = span.down('img', 0);
    if(!del_img)return;
    del_img.src = "/images/del_hoover.gif";
}

function normalDel(span){
    if(disableStatementTableScript)return;
    var del_img = span.down('img', 0);
    if(!del_img)return;
    del_img.src = "/images/del.gif";
}

function parseTableIntoYDataSet(tableId, definedTypesByStatementType){
    var table = $(tableId);
    var store = {};
    var xTicks = [];
    var definedTypes = null;
    if(definedTypesByStatementType){
        definedTypes = definedTypesByStatementType.get(statement_type);
    }
    var rows = Selector.findChildElements(table.down('tbody'),['tr']);
    for(var i=0,incr=-1,size=rows.length;i<size;i++){
        var row = rows[i];
        if(definedTypes){
           var level = row.readAttribute('value')*1;
           if(!definedTypes.include(level)){
             continue;
           }
         }
        incr++;
        var cells =  Selector.findChildElements(row, ['td']);
        for(var j=0,jsize=cells.length;j<jsize;j++){
            var cell = cells[j];
            if(j==0){
               var value = cell.innerHTML;
               var index = value.toLowerCase().indexOf('</span>');
               if(index != -1){
                  index += 7;
               }else{
                  index = 0;
               }
               value = value.substring(index,value.length);
               xTicks[incr]= {v:incr, label: value};
            }else{
               var value = cell.innerHTML;
               value = value.stripTags();
               var curIndex = j-1;
               var cellValues = store[curIndex];
               if(!cellValues){
                  cellValues = [];
                  store[curIndex] = cellValues;
               }
               cellValues[cellValues.length]=[incr, parseInt(value)];
            }
        }
    }  
    
    return [store, xTicks]; 
}

function drawTableChart(tableId, plotrIdHolder, plotrDetailHolder){
    drawDetailedTableChart(tableId, plotrIdHolder, GRAPH_SUMMURY_ACC_BY_STAT_TYPE);
    drawDetailedTableChart(tableId, plotrDetailHolder);
}
function drawDetailedTableChart(tableId, plotrIdHolder, summary_acc_types) {
   var tableResults = parseTableIntoYDataSet(tableId, summary_acc_types);
   var store = tableResults[0];
   var xTicks = tableResults[1];
   if (xTicks.length == 0)
       return;
   var options = null;
   
   if(summary_acc_types){
      options = {
		backgroundColor: '#E6F2FF',
		colorScheme: 'blue',
		xTicks: xTicks,
		axisLabelWidth: 120,
		axisLabelFontSize: 	11,
		padding: {left: 66, right: 0, top: 10, bottom: 12},
		yNumberOfTicks: 4,
		barOrientation: 'vertical'
	  };
   }else{
      options = {
		backgroundColor: '#E6F2FF',
		colorScheme: 'red',
		xTicks: xTicks,
		axisLabelFontSize: 	11,
        padding: {left: 100, right: 30, top: 5, bottom: 10},
		barOrientation: 'horizontal'
	 };
   }

    $(plotrIdHolder).innerHTML = "";

    var c = document.createElement("canvas");
    c.id=plotrIdHolder + "-graph";
    if(summary_acc_types){
        c.height="110";
        c.width="590";
    }else{
        c.width="980";
        c.height=xTicks.length*70;
    }
    
    $(plotrIdHolder).appendChild(c);
    
    if (typeof G_vmlCanvasManager != "undefined") {
        G_vmlCanvasManager.initElement(c);
    }
    
    
	var bar = new Plotr.BarChart(c.id, options);
	bar.addDataset(store);
	bar.render();
}

function init_add_portfolio(){
    onPortfolioTypeChange($('transaction_type'), true);
    autoCompleteStockSymbol();
    initCalendar();
    var acl = new Form.Element.DelayedObserver('pitch', 0.1, function(){display_preview($('pitch'), 'pitch_display_preview');});
}

function focus_on(element_id){
  var foc_el = $(element_id);
  if (foc_el){foc_el.select()}; 
}

function initModalWin(linkId, content, focused_id){
  var m = new Control.Modal($(linkId),{containerClassName: 'modal_container', 
        contents: function(){return content},
        afterOpen: function(){
            focus_on(focused_id);
            if(linkId == "portfolio_add_link"){
              init_add_portfolio();
            }
        },
        afterClose: function(){hideCalendar();current_stock_symbol = null;}
       });
}

function initModalWinForTable(linkId){
  var m = new Control.Modal($(linkId),{opacity: 0.75, containerClassName: 'modal_container', 
       contents: function(){return $('ajax-carousel-li'+statement_type).innerHTML;}, 
       afterOpen: function(){disableStatementTableScript = true;}, 
       beforeClose: function(){disableStatementTableScript = false;}});
  return m;
}

var close_win_modal_popup = false;
var close_win_call_all = false;
function initModalWinForCompaniesTable(linkId){
  close_win_modal_popup = false;
  close_win_call_all = false;
  var element = $(linkId);
  var prev_onclick = element.onclick;
  var str = "<div id='companies_confirm'>This action could take longer time to respond. Do you want to continue?<br/><br/><center>";
  str += "<a href='#' onclick='close_win_modal_popup=true;close_win_call_all=true;Control.Modal.current.close();'>Yes</a>";
  str += "&nbsp;<a href='#' onclick='close_win_modal_popup=true;Control.Modal.current.close();'>No</a>";
  str += "</center><div>";
  var m = new Control.Modal(element,{containerClassName: 'modal_container', 
       contents: function(){return str}, 
       beforeClose: function(){return close_win_modal_popup;},
       afterClose: function(){if(close_win_call_all){close_win_modal_popup=false;prev_onclick();}else{close_win_modal_popup=false;}}
       });
  return m;
}

function updateStatementParm(link){
    var href = link.href;
    href = href.substring(0,href.length-1);
    href = href+statement_type;
    if(annualized){
        href = href + '&ann=y';
    }
    link.href = href;
    return true;
}



/********************************************** Auth *********************************************/

/*
 * This is used with The account facility
 *
 * Fabien Penso <penso@linuxfr.org>
 */

function load_page() {
	 if (document.getElementById('post_login')) {
     if (document.getElementById('post_login').value == '') {
       document.getElementById('post_login').focus();
     } else if (document.getElementById('post_password'))  {
       document.getElementById('post_password').focus();
     }
	 } else if(document.getElementById('post_email')) {
		 document.getElementById('post_email').focus();
	 }
}

/**
 * Prevent load_page from breaking other onload events
**/
if (typeof Behavior != 'undefined') {
  Behavior.addLoadEvent(load_page);
} else {
  if (typeof addLoadEvent != 'function') {
    function addLoadEvent(func) {
      var old_onload = window.onload;
      if (typeof window.onload != 'function') {
	    window.onload = func;
	  } else {
	    window.onload = function() { old_onload; func; }
	  }
    }
  }
  addLoadEvent(load_page);
}

/********************************************** \Auth *********************************************/

/********************************************** Portfolio *********************************/
function display_preview(element, observer_id){
    var observer = $(observer_id);
    observer.innerHTML = element.value;
}

function onPortfolioTypeChange(drd, added){
    if(drd == null){return;}
    if(drd.value == "Buy"){
        switchColumn("option_date_th", true, null, added);
        switchColumn("portfolio_price_th", true, null, added);
    }else{
        switchColumn("option_date_th", false, null, added);
        switchColumn("portfolio_price_th", false, null, added);
    }
}

function autoCompleteStockSymbol(){
    if($('add_symbol')){
        new Ajax.Autocompleter('add_symbol', 'pf_auto_comp_div', '/search/auto_complete_for_search_term', {method: 'get'});  
     }
     focus_on('add_symbol');
}

var current_stock_symbol = null;
function loadStockProp(){
    var add_symbol_field = $('add_symbol');
    if(!add_symbol_field || !add_symbol_field.value){return;}
    if(current_stock_symbol && current_stock_symbol == add_symbol_field.value ){return;}
    
    current_stock_symbol = add_symbol_field.value;
    requestStockProp(current_stock_symbol);
}

function requestStockProp(stock_symbol){
  var url = '/markets/'+ stock_symbol
  var myAjax = new Ajax.Request(
          url, 
        { method: 'get', 
          requestHeaders: {Accept: 'application/json'},
          asynchronous: true,
	  onSuccess: showStockResponse
	});
}

function showStockResponse(xhr){
    var market = xhr.responseText.evalJSON();
    var curr_price = 'Current Price:<br/> ' + market.last_traded_price/100 + " ("+market.currency +")";
    var update_price1 = $('stock_price1');
    update_price1.innerHTML = curr_price;
    new Effect.Highlight(update_price1);
    var update_price2 = $('stock_price2');
    update_price2.innerHTML = curr_price;
    new Effect.Highlight(update_price2);
}

function truncateNumber(str){
   str = str.toString();
   var dot = str.indexOf(".");
   str = str.truncate(dot, suffix = '');
   str = str*1;
   return str;
}
/********************************************** End:Portfolio *********************************/


/********************************************** CALENDAR *********************************************/

function leadingZero(x){
   return (x>9)?x:'0'+x;
}

function formatDate(date) {
   return date.getFullYear() + '-' + (leadingZero(date.getMonth() + 1)) + '-' + leadingZero(date.getDate());
}

var calendarObjForForm = null; 
function initCalendar(){
    if (calendarObjForForm == null) {
       calendarObjForForm = new DHTMLSuite.calendar({callbackFunctionOnDayClick:'getDateFromCalendar',isDragable:true,displayTimeBar:false}); 
    }
}

var calendarOpen = false;
function hideCalendar(){
     if (calendarObjForForm && calendarOpen) {
         calendarObjForForm.hide();
     }
}


function pickDate(inputObject){
    calendarOpen = true;
    if(inputObject.value == 'Today'){
        inputObject.value = formatDate(new Date());
    }
    calendarObjForForm.setCalendarPositionByHTMLElement(inputObject,0,inputObject.offsetHeight+2);	
    calendarObjForForm.setInitialDateFromInput(inputObject,'yyyy-mm-dd');
    calendarObjForForm.addHtmlElementReference('option_date',inputObject);
    if(calendarObjForForm.isVisible()){
	calendarObjForForm.hide();
    }else{
	calendarObjForForm.resetViewDisplayedMonth();
	calendarObjForForm.display();
    }		
}

function getDateFromCalendar(inputArray){
	var references = calendarObjForForm.getHtmlElementReferences();
	references.option_date.value = inputArray.year + '-' + inputArray.month + '-' + inputArray.day;
	calendarObjForForm.hide();
        calendarOpen = false;
        $('portfolio_price').select();	
}

/********************************************** \CALENDAR *********************************************/
	
