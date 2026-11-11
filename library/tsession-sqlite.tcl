# SPDX-License-Identifier: MIT
package require tsession 1.1.0
package require tsession::sql 1.1.0
package require tdbc::sqlite3 1.1.8
namespace eval ::tsession::sqlite {}
proc ::tsession::sqlite::create {args} {
    ::tsession::sql::create sqlite {*}$args
}
proc ::tsession::sqlite::initdb {connection} {
    ::tsession::sql::initdb $connection sqlite
}
package provide tsession-sqlite 1.0.0
