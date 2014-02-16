#!/bin/sh

daily_zfs_snapshot_enable="YES"
daily_zfs_snapshot_pools="zones"
daily_zfs_snapshot_keep=3

case "$daily_zfs_snapshot_enable" in
    [Yy][Ee][Ss])
        . /opt/local/bin/zfs_snapshot.sh
        do_snapshots "$daily_zfs_snapshot_pools" $daily_zfs_snapshot_keep 'daily'
        ;;
    *)
        ;;
esac
