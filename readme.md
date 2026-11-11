# tsession-sqlite

SQLite session persistence for `tsession` 2.0.0. Each store borrows a
`tpersist` connection and scopes every operation to a tenant. There is no global
active store. `web-user` selects this package for `LOCAL`.

```tcl
package require tsession-sqlite 1.0.1
set db [::tpersist::db_connect -dialect sqlite -database ./sessions.sqlite3 -autobegin 0]
# Run explicitly before serving requests; create never changes the schema.
::tsession::sqlite::initdb $db
set store [::tsession::sqlite::create -connection $db -tenant my-site]
set expires [expr {[clock seconds] + 3600}]
::tsession::sql::insert $store opaque-id [dict create expires $expires user_id user-1] user-1
set session [::tsession::sql::get $store opaque-id]
::tsession::sql::update $store opaque-id [dict create preference dark]
::tsession::sql::delete $store opaque-id
::tpersist::db_disconnect $db
```

The factory rejects any connection whose dialect is not `sqlite`. The host
owns and closes the connection, one per worker. Use `-autobegin 0` when opening
it; explicit `tpersist::db_transaction` scopes group account and session changes.
Store operations never independently commit or roll back that connection.
The host creates the SQLite parent directory and configures its connection timeout.

The common API is provided by `tsession::sql` (bundled with `tsession`):

| Operation | Behavior |
| --- | --- |
| `insert store id data ?subject?` | Insert a new ID. Data must be a dictionary with integer `expires` (Unix seconds). Duplicate IDs fail. |
| `get store id` | Return the dictionary with canonical `id`/`expires`, or an empty dictionary for missing/expired records. |
| `update store id changes` | Merge fields using a revision check. Return 1 on success, 0 for missing, expired, revoked or concurrently changed records. ID and subject cannot change. |
| `delete store id` | Delete this tenant's ID and return the affected row count. |
| `revoke store subject` | Delete all this tenant's sessions for a nonempty subject, returning the count. |
| `prune store` | Delete this tenant's expired records, returning the count. |

`expires <= clock seconds` is expired. Reading never extends the lifetime;
updates cannot revive expired or revoked records. Hosts schedule `prune`.
`tsession_sessions` has a `(tenant, id)` primary key plus subject/expiry indexes.
Dictionaries are bound as text and never evaluated as Tcl scripts. Sensitive
fields must be encrypted by the caller. `web-user` stores token MACs as IDs and
encrypts pending MFA secrets. No migration or old middleware adapter is included.

Install with CMake (`-DBUILD_TESTING=OFF` for installation), or add the checkout
to `TCLLIBPATH`. Requires Tcl 8.6.14+, tpersist 0.1.2+, tsession 2.0.0+, and
TDBC's SQLite driver 1.1.8+.

```sh
tclsh tests/all.tcl
```

Tests cover persistence across reconnects, expiry, revocation, tenant isolation,
validation, and rollback with the caller's transaction. PostgreSQL tests require
an isolated database and skip when `TSESSION_TEST_PG` is unset.
