#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="redis-server"

nodejs_version=14

# Dependencies for AbiWord
abiword_app_depencencies="abiword"

# Dependencies for LibreOffice
libreoffice_app_dependencies="unoconv libreoffice-writer"

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================

#=================================================
# REDIS HELPERS
#=================================================

# get the first available Redis database
#
# usage: ynh_redis_get_free_db
# | returns: the database number to use
ynh_redis_get_free_db() {
    local result max db
    result="$(redis-cli INFO keyspace)"

    # get the num
    max=$(cat /etc/redis/redis.conf | grep ^databases | grep -Eow "[0-9]+")

    db=0
    # default Debian setting is 15 databases
    for i in $(seq 0 "$max")
    do
        if ! echo "$result" | grep -q "db$i"
        then
            db=$i
            break 1
        fi
        db=-1
    done

    test "$db" -eq -1 && ynh_die --message="No available Redis databases..."

    echo "$db"
}

# Create a master password and set up global settings
# Please always call this script in install and restore scripts
#
# usage: ynh_redis_remove_db database
# | arg: database - the database to erase
ynh_redis_remove_db() {
    local db=$1
    redis-cli -n "$db" flushall
}


# Create a master password and set up global settings
# Please always call this script in backup script
#
# usage: ynh_redis_dump_db database
# | arg: database - the database to dump
ynh_redis_dump_db() {
    # Declare an array to define the options of this helper.
    local legacy_args=d
    local -A args_array=([d]=database=)
    local database
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"

    local db=$1
    redis-cli redis-dump -d "$db"
}
