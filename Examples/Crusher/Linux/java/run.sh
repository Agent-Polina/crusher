CRUSHER_DIR=/path/to/crusher

sudo $CRUSHER_DIR/bin_x86-64/fuzz_manager --start 2 --eat-cores 1 --dse-cores 0 -F --wait-next-instance 20000 --auto-stop-target-server --tcp-recv-response --docker ubuntu-keycloak-fuzz -i ${PWD}/in -t 200000 --java-jacoco-trace --no-affinity --max-file-size 10M --port 8080 -o $(pwd)/out -I javajacoco --ip 127.0.0.1 --delay 200000 -T NetworkTCP --jvm-options $(pwd)/config.json  -- $(pwd)/keycloak-26.0.7/lib/quarkus-run.jar io.quarkus.bootstrap.runner.QuarkusEntryPoint --profile=dev start-dev
