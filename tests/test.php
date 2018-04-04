<?php

/*
 *  Test PHP 7 function types : shouldn't work if PHP < 7.0
 */
function foo(): string {
	    return 'hello world';
}

print foo();
?>
