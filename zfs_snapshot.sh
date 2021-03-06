#!/bin/sh

# checks to see if there's a scrub in progress
scrub_in_progress()
{
  pool=$1

  if zpool status $pool | grep "scrub in progress" > /dev/null; then
    return 0
  else
    return 1
  fi
}

# take the appropriately named snapshot
create_snapshot()
{
    pool=$1

    case "$type" in
        hourly)
        now=`date +"$type-%Y-%m-%d-%H"`
        ;;
        daily)
        now=`date +"$type-%Y-%m-%d"`
        ;;
        weekly)
        now=`date +"$type-%Y-%U"`
        ;;
        monthly)
        now=`date +"$type-%Y-%m"`
        ;;
        *)
        echo "unknown snapshot type: $type"
        exit 1
    esac

    # create the now snapshot
    snapshot="$pool@$now"
    # look for a snapshot with this name
    if zfs list -t snapshot -H -o name | sort | grep "$snapshot$" > /dev/null; then
        echo "  snapshot, $snapshot, already exists"
    else
        echo "  taking snapshot, $snapshot"
        zfs snapshot -r $snapshot
    fi
}

# delete the named snapshot
delete_snapshot()
{
    snapshot=$1
    echo "      destroying old snapshot, $snapshot"
    zfs destroy -r $snapshot
}

# take a type snapshot of pool, keeping keep old ones
do_pool()
{
    pool=$1
    keep=$2
    type=$3

    # create the regex matching the type of snapshots we're currently working
    # on
    case "$type" in
        hourly)
        # hourly-2009-01-01-00
        regex="$pool@$type-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$"
        ;;
        daily)
        # daily-2009-01-01
        regex="$pool@$type-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$"
        ;;
        weekly)
        # weekly-2009-01
        regex="$pool@$type-[0-9][0-9][0-9][0-9]-[0-9][0-9]"
        ;;
        monthly)
        # monthly-2009-01
        regex="$pool@$type-[0-9][0-9][0-9][0-9]-[0-9][0-9]"
        ;;
        *)
        echo "unknown snapshot type: $type"
        exit 1
    esac

    create_snapshot $pool $type

    # get a list of all of the snapshots of this type sorted alpha, which
    # effectively is increasing date/time
    # (using sort as zfs's sort seems to have bugs)
    snapshots=`zfs list -t snapshot -H -o name | sort | grep $regex`
    # count them
    count=`echo $snapshots | wc -w`
    if [ $count -ge 0 ]; then
        # how many items should we delete
        delete=`expr $count - $keep`
        count=0
        # walk through the snapshots, deleting them until we've trimmed deleted
        for snapshot in $snapshots; do
            if [ $count -ge $delete ]; then
                break
            fi
            delete_snapshot $snapshot
            count=`expr $count + 1`
        done
    fi
}

# take snapshots of type, for pools, keeping keep old ones,
do_snapshots()
{
    pools=$1
    keep=$2
    type=$3

    echo ""
    echo "Doing zfs $type snapshots:"
    for pool in $pools; do
        if scrub_in_progress $pool; then
          echo "        skipping snapshot of $pool, scrub in progress"
        else
          do_pool $pool $keep $type
        fi
    done
}
