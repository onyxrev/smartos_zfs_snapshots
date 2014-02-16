#!/bin/sh

hourly_zfs_snapshot_enable="YES"
hourly_zfs_snapshot_pools="zones"
hourly_zfs_snapshot_keep=23

case "$hourly_zfs_snapshot_enable" in
    [Yy][Ee][Ss])
        . /opt/local/bin/zfs_snapshot.sh
        do_snapshots "$hourly_zfs_snapshot_pools" $hourly_zfs_snapshot_keep 'hourly'
        ;;
    *)
        ;;
esac
