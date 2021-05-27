<?php

session_start();

if(isset($_GET['name'])) {
  $_SESSION['name'] = $_GET['name'];
}


if(!isset($_SESSION['name'])) {
  print("Is the anybody out there?");
} else {
  printf("Hello %s", $_SESSION['name']);
}

