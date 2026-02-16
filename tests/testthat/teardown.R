options(old_opts)
lg_bbotk$set_threshold(old_threshold_bbotk)
lg_rush$set_threshold(old_threshold_rush)


if (has_redis) {
  system("kill $(cat /tmp/redis-rush.pid) && rm -f /tmp/redis-rush.sock /tmp/redis-rush.pid")
}
