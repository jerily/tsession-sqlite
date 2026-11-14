# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Register the package and load its dependencies.
package require tsession 2.0.1
package require tsession::sql 2.0.1
package require tdbc::sqlite3 1.1.8
namespace eval ::tsession::sqlite {}
proc ::tsession::sqlite::create {args} {
    ::tsession::sql::create sqlite {*}$args
}
proc ::tsession::sqlite::initdb {connection} {
    ::tsession::sql::initdb $connection sqlite
}
package provide tsession-sqlite 1.0.2
