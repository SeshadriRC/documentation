# Database CLI Commands for DevOps Engineers

A comprehensive reference for production database operations, backup/restore pipelines, connection pooling triage, slow query diagnostics, and caching with PostgreSQL, MySQL, Redis, and MongoDB.

---

## 1. PostgreSQL (`psql`, `pg_dump`, `pg_restore`)

### Connection & Health Checks

```bash
# Check if PostgreSQL server is accepting connections (ideal for Docker/K8s readiness probes)
pg_isready -h localhost -p 5432 -U postgres

# Connect to database via interactive psql shell
psql -h db.internal -p 5432 -U appuser -d production_db

# Run a non-interactive SQL query from bash
psql -h localhost -U postgres -d mydb -c "SELECT version();"

# Run an SQL script file
psql -h localhost -U postgres -d mydb -f /path/to/migration.sql
```

### Backup & Restore

```bash
# Create custom-format compressed backup (-F c: supports parallel restore)
pg_dump -h localhost -U postgres -d production_db -F c -b -v -f /backups/prod_$(date +%F).dump

# Plain text SQL dump (gzipped on the fly)
pg_dump -h localhost -U postgres -d production_db | gzip > /backups/prod_backup.sql.gz

# Dump schema only (no table data)
pg_dump -h localhost -U postgres -d production_db --schema-only -f schema.sql

# Restore from custom-format backup (.dump)
pg_restore -h localhost -U postgres -d production_db -v /backups/prod_backup.dump

# Parallel restore with 4 worker threads into clean database
pg_restore -h localhost -U postgres -d production_db -j 4 --clean --if-exists /backups/prod_backup.dump
```

### DevOps Troubleshooting & Performance Queries

```sql
-- View top active connections and long-running queries (Run inside psql)
SELECT pid, client_addr, now() - query_start AS duration, state, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC
LIMIT 10;

-- Terminate a stuck / blocking query gracefully (cancels query, keeps connection)
SELECT pg_cancel_backend(12345);

-- Forcefully kill a rogue database connection
SELECT pg_terminate_backend(12345);

-- Check database disk sizes
SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;

-- Identify top 10 largest tables in the database
SELECT relname AS table_name, pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```

---

## 2. MySQL & MariaDB (`mysql`, `mysqldump`)

### Connection & Health Checks

```bash
# Ping MySQL server to verify connectivity
mysqladmin -h localhost -u root -p ping

# Interactive MySQL shell
mysql -h db.internal -u appuser -p production_db

# Execute single command and format results vertically (\G)
mysql -h localhost -u root -p -e "SHOW SLAVE STATUS\G;"
```

### Backup & Restore

```bash
# Consistent non-blocking backup of transactional tables (InnoDB)
mysqldump -h localhost -u root -p \
  --single-transaction \
  --quick \
  --lock-tables=false \
  --routines \
  --triggers \
  production_db > /backups/mysql_prod_$(date +%F).sql

# Dump all databases
mysqldump -h localhost -u root -p --all-databases --single-transaction > all_databases.sql

# Restore database from SQL dump
mysql -h localhost -u root -p production_db < /backups/mysql_prod.sql
```

### DevOps Troubleshooting & Queries

```sql
-- Inspect all running queries and execution threads (Run inside mysql)
SHOW FULL PROCESSLIST;

-- Kill a long-running thread or query
KILL 42;

-- Check database sizes
SELECT table_schema AS "Database",
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.tables
GROUP BY table_schema;

-- Check replication lag (on replica node)
SHOW REPLICA STATUS\G
```

---

## 3. Redis (`redis-cli`)

### Connection & Diagnostics

```bash
# Ping Redis server (should reply PONG)
redis-cli -h localhost -p 6379 ping
redis-cli -h localhost -p 6379 -a "MyStrongPassword" ping

# Inspect memory statistics (used memory, peak memory, fragmentation ratio)
redis-cli -h localhost info memory

# Inspect replication topology (role: master/slave, connected slaves)
redis-cli -h localhost info replication

# Check general server stats (connected clients, total ops per second)
redis-cli -h localhost info stats
```

### Troubleshooting & DevOps Operations

```bash
# Monitor all commands processed by Redis in real-time (caution: high CPU impact in production)
redis-cli -h localhost monitor

# Retrieve slow query log entries (commands exceeding slowlog-log-slower-than threshold)
redis-cli -h localhost slowlog get 10

# Scan keys safely without blocking Redis (NEVER run 'KEYS *' in production)
redis-cli -h localhost --scan --pattern "session:*" | head -n 20

# Trigger asynchronous snapshot save to dump.rdb
redis-cli -h localhost bgsave

# Check last successful save timestamp
redis-cli -h localhost lastsave

# Flush all keys in current database (Destructive)
redis-cli -h localhost flushdb async

# Flush all keys across ALL databases (Destructive)
redis-cli -h localhost flushall async
```

---

## 4. MongoDB (`mongosh`, `mongodump`, `mongorestore`)

### Connection & Administration

```bash
# Connect using connection string
mongosh "mongodb://appuser:secret@localhost:27017/my_db?authSource=admin"

# Check replica set status (Run inside mongosh)
rs.status()

# Server ping and status
db.runCommand({ ping: 1 })
db.serverStatus()
```

### Backup & Restore

```bash
# Dump entire MongoDB instance to archive file with compression
mongodump --uri="mongodb://root:secret@localhost:27017" --archive=/backups/mongo_$(date +%F).archive --gzip

# Restore from compressed archive
mongorestore --uri="mongodb://root:secret@localhost:27017" --archive=/backups/mongo_backup.archive --gzip --drop
```

### Performance & Query Killing

```javascript
// Find operations running for more than 5 seconds
db.currentOp({ "active": true, "secs_running": { "$gt": 5 } });

// Kill operation by OpID
db.killOp(12345);
```
