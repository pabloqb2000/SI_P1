PGDATABASE = si1
PGUSER = alumnodb
PGPASSWORD = alumnodb
DBFILE = sql_files/dump_v1.4.sql.gz
SQL_UPDATE_FILE = sql_files/actualiza.sql
SQL_PRICE_FILE = sql_files/setPrice.sql
SQL_ORDER_FILE = sql_files/setOrderAmount.sql


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

	
