<?php

$units = array(
	'k' => 1000,
	'M' => 1000000,
	'G' => 1000000000,
);

$memoryLimit = getenv('MEMORYLIMIT');
if ($memoryLimit == '') {
	$memoryLimit = '128M';
}
$ml = substr($memoryLimit, 0, -1) * $units[substr($memoryLimit, -1)];

$workers = getenv('WORKERS');
if ($workers == '' ) {
	$workers = 5;
}
if($workers == 'auto') {
	$procs = 0;
	$f = trim(file_get_contents("/sys/fs/cgroup/cpu/cpu.cfs_quota_us"));
	if ($f != "-1") {
		$procs = $f / 100000;
	} else {
		$f = file_get_contents("/proc/cpuinfo");
		foreach (explode("\n", $f) as $line) {
			if (strstr($line, 'processor')) {
				$procs++;
			}
		}
	}
	$memory = trim(file_get_contents("/sys/fs/cgroup/memory/memory.limit_in_bytes"));
	$workers = floor($memory / $ml);
	// 2 is max worker per cpu
	if ($workers > ($procs * 2)) {
		$workers = $procs * 2;
	}
}

print $workers;
?>
