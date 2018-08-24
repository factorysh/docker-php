Testing image with Goss
=======================

Tests are running inside container context, using volumes and lazy downloaded `goss` binary.

Test are running with the `Makefile` in parent folder, with `make tests`.

`php-dev.yaml`: main playbook. Imports all tests.

`*.yaml` : differents tests.

test.php : test new PHP 7.0 features
