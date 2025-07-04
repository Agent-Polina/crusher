# Общее описание

Ниже приведён пример фаззинг-тестирования Java-приложения на базе Keycloak — программ-
ного продукта с открытым исходным кодом, представляющего собой сервер идентификации и
управления доступом.

# Подготовка к фаззинг-тестированию

`Keycloak` запускается в JVM с помощью скрипта `./target/keycloak-26.0.7/bin/kc.sh`, который автоматически формирует и передает параметры Java.
 Чтобы получить эти параметры, в скрипте запуска kc.sh была изменена последняя строка на следующую:

```
eval exec echo "'$JAVA'" $JAVA_RUN_OPTS
```

После запуска скрипта kc.sh полученные JVM-параметры были добавлены в конфигурационный файл config.json.
 
# Фаззинг-тестирование в один поток
 Запустите фаззинг-тестирование:

```bash
/path/to/crusher/bin_x86-64/fuzz -i in -o out -t 200000 --auto-stop-target-server \     
-T NetworkTCP --port 8080 --ip 127.0.0.1 --delay 200000 -I javajacoco --jvm-options \
./config.json -- ./keycloak-26.0.7/lib/quarkus-run.jar \
io.quarkus.bootstrap.runner.QuarkusEntryPoint --profile=dev start-dev

```
где:

* `-i` - директория с начальным корпусом входных данных;
* `-o` - директория для результатов;
* `-t`  - таймаут на запуск приложения (в мс);
* `--auto-stop-target-server` - автоматическое завершение процесса анализируемого сервера после того, как он закрывает сокет передачи данных;
* `-T NetworkTCP` -  передача входных данных по TCP;
* `--port 8080` - порт, использующийся для передачи пакетов;
* `--ip 127.0.0.1` - IP-адрес для подключения;
* `--delay` - время ожидания (в мс) на установление соединения с сервером;
* `-I javajacoco` - тип инструмнтации Java без форк-сервера;
* `-- ./keycloak-26.0.7/lib/quarkus-run.jar` - путь к исполняемому JAR-файлу;
* `io.quarkus.bootstrap.runner.QuarkusEntryPoint` - путь к основному классу, содержащему метод main() — точку входа в приложение;
* `--profile=dev` - запуск в режиме разработчика (опция keycloak);
* `start-dev` - аргумент запуска Keycloak в dev-режиме (как в скрипте kc.sh).

Примечание: при запуске фаззинг-тестирования в однопоточном режиме HTML-отчёт о покрытии
не формируется.

В данном примере будет наблюдаться рост покрытия. В директории `/path/to/out/EAT_OUT/queue` будут находиться файлы с входными данными, которые приводят к нормальному завершению и росту покрытия.  

**Фаззинг-тестирование в несколько потоков**

При параллельном фаззинг-тестировании `Keycloak` возможны конфликты из-за использования одного и того же TCP-порта (8080). Для изоляции окружений в данном примере используется запуск в Docker-контейнерах.

В `Dockerfile` в строке Х необходимо указать правильный путь до keycloak-26.0.7.

Примечание: Используйте только латинские символы в путях и названиях файлов.

Создайте Docker-образ:

```shell
docker build -t ubuntu-keycloak-fuzz --build-arg USER_ID=$(id -g) \
        --build-arg USER_NAME=$(id -un) --build-arg GROUP_ID=$(id -g) \
        -f Dockerfile .
```

где:

* `build` - создание образа из `Dockerfile`;
* `-t ubuntu-keycloak-fuzz` - указывается имя Docker-образа;
* `--build-arg USER_ID=$UID` - ID пользователя в основной системе передаётся в качестве ID пользователя внутри Docker-образа;
* `--build-arg USER_NAME=$(id -un)` - имя пользователя в основной системе передаётся в качестве имени пользователя внутри Docker-образа;
* `--build-arg GROUP_ID=$(id -g)` - ID группы пользователя в основной системе передаётся в качестве ID группы пользователя внутри Docker-образа;
* `-f Dockerfile` - указывается название `Dockerfile`, который необходимо собрать;
* `.` - указание рабочей директории Docker-образа.

Создайте файл `config_docker.json`, скопировав содержимое `config.json`, и замените все пути на те, которые используются внутри Docker-контейнера (как в `Dockerfile`).

Запустите фаззинг-тестирование:

```bash
/path/to/crusher/bin_x86-64/fuzz_manager --start 2 --eat-cores 1 --dse-cores 0 -F \
 --wait-next-instance 20000 --auto-stop-target-server --tcp-recv-response \
 --docker ubuntu-keycloak-fuzz -i /path/to/in -t 200000 --java-jacoco-trace --no-affinity \
--max-file-size 10M --port 8080 -o path/to/out -I javajacoco --ip 127.0.0.1 --delay 200000 \ 
-T NetworkTCP --jvm-options /path/to/config_docker.json \
-- /path/to/keycloak-26.0.7/lib/quarkus-run.jar io.quarkus.bootstrap.runner.QuarkusEntryPoint \
--profile=dev start-dev
```

где:

* `--wait-next-instance` - временной интервал (мс) между запусками процессов fuzz и eat;
* `--tcp-recv-response ` - получение ответа от анализируемого TCP-сервера;
* `--docker` - Docker-образ;
* `--java-jacoco-trace` - формирование отчета об покрытии;
* `--no-affinity` - отключение привязки процессов к свободным ядрам;
* `--max-file-size` - максимальный размер файла в начальном корпусе входных данных.

Пользовательский интерфейс UI
Запустите в другом терминале пользовательский интерфейс UI:


```bash
/path/to/crusher/bin_x86-64/ui --outdir /path/to/out
```
Просмотр отчета о покрытии

Перенесите директорию с отчётом на уровень выше каталога `out` и задайте для неё права доступа:

```
cp -r /path/to/out/.tmp/JavaJacocoTrace/report /path/to

chmod -R a+r /path/to/report
```
Откройте отчет: 

```bash
xdg-open /path/to/report/index.html
```
Отчет содержит информацию о покрытии по инструкциям и ветвлениям (branches) на уровне JVM.

