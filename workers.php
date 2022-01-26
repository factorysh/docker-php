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
	$f = file_get_contents("/proc/cpuinfo");
	foreach (explode("\n", $f) as $line) {
		if (strstr($line, 'processor')) {
			$procs++;
		}
	}
	$f = file_get_contents("/proc/meminfo");
	foreach (explode("\n", $f) as $line) {
		if (strstr($line, 'MemTotal:')) {
			preg_match('/\w+:\s+(\d+) (\w)B/', $line, $matches);
			$memory = $matches[1] * $units[$matches[2]];
		}
	}
	$workers = floor($memory / $ml);
	// 2 is max worker per cpu
	if ($workers > ($procs * 2)) {
		$workers = $procs * 2;
	}
}

print $workers;
?>
