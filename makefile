PGDATABASE = si1
PGUSER = alumnodb
PGPASSWORD = alumnodb
DBFILE = sql_files/dump_v1.4.sql.gz
SQL_UPDATE_FILE = sql_files/actualiza.sql
SQL_PRICE_FILE = sql_files/setPrice.sql
SQL_ORDER_FILE = sql_files/setOrderAmount.sql
SQL_SALES_FILE = sql_files/getTopSales.sql
SQL_ACTORS_FILE = sql_files/getTopActors.sql
SQL_UPDORDERS_FILE = sql_files/updOrders.sql

all: reset_db set_price set_order_amount get_top_sales get_top_actors updOrders

reset_db: clear_db create_db update_db

execute_files: set_price set_order_amount

clear_db:
	@echo Clear Database
	dropdb --if-exists $(PGDATABASE) -U $(PGUSER)

create_db:
	createdb -U $(PGUSER) $(PGDATABASE)
	gunzip -c $(DBFILE) | psql $(PGDATABASE) $(PGUSER) 

update_db:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_UPDATE_FILE)
	
set_price:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_PRICE_FILE)

set_order_amount:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_ORDER_FILE)

get_top_sales:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_SALES_FILE)

get_top_actors:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_ACTORS_FILE)

updOrders:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_UPDORDERS_FILE)

temp: updOrders
	psql $(PGDATABASE) $(PGUSER) -f sql_files/temp.sql

	
