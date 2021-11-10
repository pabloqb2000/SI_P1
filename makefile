PGDATABASE = si1
PGUSER = alumnodb
PGPASSWORD = alumnodb
DBFILE = sql_files/dump_v1.4.sql.gz
SQL_UPDATE_FILE = sql_files/actualiza.sql
SQL_PRICE_FILE = sql_files/setPrice.sql


reset_db: clear_db create_db update_db set_price_db

clear_db:
	@echo Clear Database
	dropdb --if-exists $(PGDATABASE) -U $(PGUSER)

create_db:
	createdb -U $(PGUSER) $(PGDATABASE)
	gunzip -c $(DBFILE) | psql $(PGDATABASE) $(PGUSER) 

update_db:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_UPDATE_FILE)
	
set_price_db:
	psql $(PGDATABASE) $(PGUSER) -f $(SQL_PRICE_FILE)

	
