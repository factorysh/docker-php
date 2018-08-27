<?php
// create a new cURL resource
$ch = curl_init();

// set URL and other appropriate options
curl_setopt($ch, CURLOPT_URL, "https://bearstech.com/");
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, True);

// grab URL and pass it to the browser
$r = curl_exec($ch);

if ($r != false) {
    print('OK');
}
// close cURL resource, and free up system resources
curl_close($ch);
?>
