if exist drop trading_companies;
if exist drop trading_companies_test;
if exist drop trading_companies_development;

create database trading_companies;
create database trading_companies_test;
create database trading_companies_development;

grant all on trading_companies.* to 'root';
grant all on trading_companies_test.* to 'root';
grant all on trading_companies_development.* to 'root';