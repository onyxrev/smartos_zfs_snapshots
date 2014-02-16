SmartOS ZFS Zones Snapshots for Cron
=====================

This is a set of scripts I use to take periodic ZFS snapshots on SmartOS.

I pretty much ripped off the FreeBSD periodic scripts found here:
http://www.neces.com/blog/technology/integrating-freebsd-zfs-and-periodic-snapshots-and-scrubs

... which I used on FreeBSD for years.  There was no license assigned to that stuff, so thanks to Ross McFarland for that work.

These scripts are a little scary because they use the zfs commands directly. They're working for me so far but I offer no warranty.  The good news is they use the -t snapshot flag, so the destructive operations are scoped to snapshots.  None the less try them on a non-critical system first.

I put these in /opt/local/bin on the global host.  They should persist there.

Add them to cron in the usual ways.  Here's mine:

```
30      *       *       *       *       /opt/local/bin/zfs_snapshot_hourly.sh > /var/log/zfs_snapshots.log
30      5       *       *       *       /opt/local/bin/zfs_snapshot_daily.sh > /var/log/zfs_snapshots.log
30      6       *       *       0       /opt/local/bin/zfs_snapshot_weekly.sh > /var/log/zfs_snapshots.log
30      7       1       *       *       /opt/local/bin/zfs_snapshot_monthly.sh > /var/log/zfs_snapshots.log
```

You'll have to develop your own strategy for getting crontab to persist across boots.  Maybe this SMF 'postboot' framework? https://github.com/skylime/smartos-config/
