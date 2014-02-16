#!/bin/sh

monthly_zfs_snapshot_enable="YES"
monthly_zfs_snapshot_pools="zones"
monthly_zfs_snapshot_keep=1

case "$monthly_zfs_snapshot_enable" in
    [Yy][Ee][Ss])
        . /opt/local/bin/zfs_snapshot.sh
        do_snapshots "$monthly_zfs_snapshot_pools" $monthly_zfs_snapshot_keep 'monthly'
        ;;
    *)
        ;;
esac
