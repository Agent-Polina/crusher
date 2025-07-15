#!/bin/bash

crusher_dir=$1

$crusher_dir/bin_x86-64/fuzz -i in -o out -t 60000 --auto-stop-target-server -T NetworkTCP --port 8080 --ip 127.0.0.1 --delay 40000  -I javajacoco  -- ./spring-petclinic/target/spring-petclinic-3.5.0-SNAPSHOT.jar org.springframework.boot.loader.launch.JarLauncher
