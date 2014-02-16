#!/bin/sh

weekly_zfs_snapshot_enable="YES"
weekly_zfs_snapshot_pools="zones"
weekly_zfs_snapshot_keep=1

case "$weekly_zfs_snapshot_enable" in
    [Yy][Ee][Ss])
        . /opt/local/bin/zfs_snapshot.sh
        do_snapshots "$weekly_zfs_snapshot_pools" $weekly_zfs_snapshot_keep 'weekly'
        ;;
    *)
        ;;
esac
