## 1. Описание примера

Нахождение аварийного завершения OpenSSL-сервера (v1.1.0a), соответствующего уязвимости CVE-2016-6309.

Демонстрируются следующие возможности фаззера:

1) Описание формата данных с помощью Peach Pit (модифицированного для Crusher).

2) Замена вызовов некоторых функций целевой программы пользовательскими во время фаззинга.
Это может ускорить запуски (особенно сетевых приложений). Более подробно - см. раздел `"PRELOAD"` в документации.

Ниже представлены все этапы от подготовки к фаззингу до воспроизведения креша.

## 2. Подготовка к фаззингу

### 2.1. Сборка докер-образа

Фаззинг будет проводиться в докер-контейнере на основе образа `openssl-fuzz:latest`, собранного следующей командой:
```shell
$ ./docker/docker_build.sh
```

Более подробно этапы сборки можно изучить в [Dockerfile](docker/Dockerfile) (оставлены комментарии).

### 2.2. Подготовка докер-контейнера:

1. Создать контейнер (укажите актуальный путь до директории `crusher`):
```shell
$ /docker/docker_run.sh <crusher_dir> [hasp_ip]
```
где:
- `crusher_dir` - директория `crusher/` (обязательная опция)
- `hasp_ip` - IP сервера лицензий (необязательная опция)

## 3. Фаззинг

1. Подготовка к запуску.
Для оптимизации обработки аварийных завершений целевой программы со статической инструментацией необходимо выполнить:
```shell
$ sudo su
$ echo core >/proc/sys/kernel/core_pattern
$ exit
```

2. Запуск фаззинга.

```shell
$ ./fuzz.sh
```

Опции фаззера:
* `--start <num>` - число fuzz-процессов (экземпляры фаззинга);
* `--eat-cores <num>` - число eat-процессов (процессы доп. анализа);
* `--dse-cores <num>` - число dse-процессов (динамическое символьное выполнение), в данном режиме не поддерживается;
* `-I <type>` - тип инструментации;
* `--peach-pit <path>` - файл с описанием формата данных (адаптированный для Crusher формат Peach Pit);
* `-i <path>` - путь до директории с начальными образцами входных данных;
* `-o <path>` - путь к выходной директории с результатами фаззинга.

3. Мониторинг.

Запустите в другом терминале `UI` фаззера (укажите актуальные пути):
```shell
$ sudo -E /path/to/crusher/bin_x86-64/ui -o out
```

Как только будут найдены креши, значение поля `unique_crashes` (в окне `UI` - наверху справа) станет ненулевым.

4. Анализ результатов.

Воспроизведение креша:

1) Получить список креш-файлов:
```shell
$ find out -name id_crash_*
```

2) Запуск сервера:
````shell
$ ./server.sh
````

3) Запуск клиента (в другом терминале):
```shell
$ python3 client.py <crash_file>
```

где `<crash_file>` - один из файлов, полученных в п. 1.

4) В терминале с сервером наблюдаем его аварийное завершение.
