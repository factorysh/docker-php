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
if(strtolower($workers) == 'auto') {
	//which version for cgroup
	$cgroupv2 = file_exists("/sys/fs/cgroup/cgroup.controllers");
	$cg_mem_file_path = $cgroupv2 ? "/sys/fs/cgroup/memory.max" : 
		"/sys/fs/cgroup/memory/memory.limit_in_bytes";
	$cg_proc_file_path = $cgroupv2 ? "/sys/fs/cgroup/cpu.max" : 
		"/sys/fs/cgroup/cpu/cpu.cfs_quota_us";
	
	$procs = 0;
	$f = trim(file_get_contents($cg_proc_file_path));
	if($cgroupv2 && strstr($f, "max") === false) {
		$t = explode($f, " ");
		$procs = $t[0] / 100000; //need to be tested 
	} 
	else if (!$cgroupv2 && $f != "-1") {
		$procs = $f / 100000;
	} else {
		$f = file_get_contents("/proc/cpuinfo");
		foreach (explode("\n", $f) as $line) {
			if (strstr($line, 'processor')) {
				$procs++;
			}
		}
	}

	$memory = trim(file_get_contents($cg_mem_file_path));
	if($cgroupv2 && $memory == "max") { // for cgroupv2
		$f = file_get_contents("/proc/meminfo");
		foreach (explode("\n", $f) as $line) {
			if (strstr($line, 'MemTotal:')) {
				preg_match('/\w+:\s+(\d+) (\w)B/', $line, $matches);
				$memory = $matches[1] * $units[$matches[2]];
			}
		}
	}
	$workers = floor($memory / $ml);
	// 2 is max worker per cpu
	if ($workers > ($procs * 2)) {
		$workers = $procs * 2;
	}
	if ($workers < 1) {
		$workers = 1;
	}
}

print $workers;

/*if(isset($argv[1])) {
	switch ($argv[1]) {
		case 'workers':
		default:
			print $workers;
			break;
		case 'min_spare_servers':
			print $procs;
			break;
		case 'max_spare_servers':
			print $procs * 2;
			break;
	}
}
else {
	print $workers;
}*/
?>
