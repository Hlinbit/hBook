
```sql
CREATE USER gpadmin;
ALTER USER gpadmin WITH CREATEDB CREATEROLE LOGIN;
GRANT ALL PRIVILEGES ON DATABASE postgres TO gpadmin;
ALTER USER gpadmin WITH SUPERUSER;
```

```bash
echo "host all testpass 127.0.0.1/32 password" >> $COORDINATOR_DATA_DIRECTORY/pg_hba.conf
echo "host all gpadmin  10.128.0.0/14 trust" >> ${COORDINATOR_DATA_DIRECTORY}/pg_hba.conf
echo "local     all     gpadmin trust" >> ${COORDINATOR_DATA_DIRECTORY}/pg_hba.conf
```