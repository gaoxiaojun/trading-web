#!/usr/bin/env ruby
ENV["RAILS_ENV"] ||= "test"
require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../domain_fountain'
require File.dirname(__FILE__) + '/../../../lib/scrapping/company_info_parser'
require File.dirname(__FILE__) + '/../../../lib/scrapping/last_traded_price_parser'
require File.dirname(__FILE__) + '/../../../lib/scrapping/scrap_bse'


      path = File.join(File.dirname(__FILE__), "/../../../tmp/scrap_archive/LastTradedPrice_2007_12_28.html")
      file = File.open path
      parser = LastTradedPriceParser.new file.readlines.to_s
      parser.store_last_traded_prices
