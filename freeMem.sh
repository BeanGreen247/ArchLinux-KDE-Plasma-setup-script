# cleans cached Memory, prevent system slowdown/lockup
sync && echo 3 > /proc/sys/vm/drop_caches
