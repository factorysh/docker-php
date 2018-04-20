<?php

require __DIR__ . '/vendor/autoload.php';

use Doctrine\Common\Inflector\Inflector;

$string = 'another-hello-world-test';

echo Inflector::ucwords($string);
