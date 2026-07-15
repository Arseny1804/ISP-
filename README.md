# Fuzzing ngIRCd with AFLNet

Лабораторная работа по фаззингу сетевых протоколов: coverage-guided
state-aware фаззинг IRC-сервера **ngIRCd** с помощью **AFLNet**.

## Почему ngIRCd

Задание требует проект на C/C++, не входящий в [ProfuzzBench](https://github.com/profuzzbench/profuzzbench),
желательно stateful, без готовых материалов по фаззингу в интернете.

Официальные субъекты ProfuzzBench — Bftpd, LightFTP, ProFTPD, Pure-FTPd (все FTP),
Dnsmasq, Kamailio, Live555, Exim, OpenSSH, OpenSSL, Tinydtls, Dcmtk, Forked-daapd.
Ни один научный туториал/статья по AFLNet или StateAFL не рассматривает ngIRCd.

ngIRCd подходит по всем критериям:
- **C**, простая autotools-сборка;
- **stateful**: клиент обязан пройти регистрацию (`PASS`/`NICK`/`USER`) прежде
  чем сервер примет остальные команды (`JOIN`, `PRIVMSG`, `MODE`...);
- **однопроцессный** (select/epoll event loop, не форкается на каждое
  соединение) — не создаёт проблем, характерных для мультипроцессных
  демонов (напр. ProFTPD) при работе с AFL forkserver;
- построчный текстовый протокол (как FTP) — простой seed-корпус.

## AFLNet не поддерживает IRC "из коробки"

AFLNet имеет встроенную поддержку разбора ответов сервера (`-P`) только
для: RTSP, FTP, MQTT, DTLS12, DNS, DICOM, SMTP, SSH, TLS, SIP, HTTP, IPP,
TFTP, DHCP, SNTP, NTP, SNMP. IRC в списке нет.

Мы реализовали собственный протокольный модуль `IRC` для AFLNet
(`extract_requests_irc`, `extract_response_codes_irc`) — см. `patches/0002`
и `patches/0003`. IRC numeric-ответы (`:server 001 nick ...`) парсятся
как второе слово строки; нечисловые команды (`JOIN`, `PRIVMSG`, ...)
хешируются в псевдо-код состояния (диапазон 1000-9999).

## Структура репозитория

```
docs/           - подробное описание эксперимента (docs/experiment.md)
patches/        - все примененные патчи (в хронологическом порядке)
scripts/        - воспроизводимые скрипты сборки/фаззинга/сравнения/coverage
seeds/          - начальный seed-корпус (полная IRC-сессия)
config/         - шаблон конфигурации ngIRCd для фаззинга
coverage/html/  - готовый LCOV HTML-отчёт о покрытии
results/        - сохранённая статистика всех прогонов (fuzzer_stats)
```

## Быстрый старт (воспроизведение)

```bash
# 1. Зависимости
sudo apt install -y build-essential autoconf automake pkg-config \
  libssl-dev zlib1g-dev clang libgraphviz-dev lcov

# 2. AFL++ должен быть установлен и в $PATH (afl-clang-fast, afl-cc)

# 3. Клонировать ngIRCd и AFLNet рядом с этим репозиторием
git clone https://github.com/ngircd/ngircd.git
git clone https://github.com/aflnet/aflnet.git

# 4. Применить патчи к AFLNet
cd aflnet
patch -p1 < ../ngircd-aflnet-fuzz/patches/0001-fix-TRUE-FALSE-undeclared-modern-graphviz.patch
patch -p1 < ../ngircd-aflnet-fuzz/patches/0002-add-irc-protocol-support.patch
patch -p1 < ../ngircd-aflnet-fuzz/patches/0003-add-irc-support-aflnet-replay.patch
# 0004 — опционально, кастомный мутатор (см docs/experiment.md)
AFL_NO_X86=1 make clean && AFL_NO_X86=1 make
cd ..

# 5. Собрать ngIRCd с инструментацией
cd ngircd && ../ngircd-aflnet-fuzz/scripts/build_ngircd_afl.sh; cd ..

# 6. Запустить фаззинг
cd ngircd-aflnet-fuzz
./scripts/fuzz_single.sh
```

Подробности каждого шага, встреченные проблемы и их решения — в
[`docs/experiment.md`](docs/experiment.md).

## Основные результаты

| Метрика | Default (30 мин) | Custom havoc-оператор (30 мин) | AFL dictionary -x (30 мин) |
|---|---|---|---|
| paths_total | 142 | 107 | 132 |
| bitmap_cvg | 2.14% | 2.07% | 2.22% |
| stability | 85.74% | 86.75% | 83.23% |
| unique_crashes | 0 | 0 | 0 |

Штатный dictionary-механизм AFL дал наибольший прирост покрытия среди
трёх вариантов (систематический перебор токенов в детерминированной
стадии эффективнее случайного havoc-оператора). Подробный разбор,
включая корректный анализ метрики stability и автомата состояний
AFLNet (ipsm.dot) — см. docs/experiment.md, разделы 9, 12, 13.

| Параллельный кластер | master | slave1 | slave2 | slave3 |
|---|---|---|---|---|
| paths_total | 213 | 265 | 249 | 246 |
| bitmap_cvg | 2.24% | 2.32% | 2.29% | 2.29% |

**LCOV coverage (по всему найденному corpus'у):** 30.8% строк (2368/7681),
48.9% функций (269/550). Полный интерактивный отчёт — `coverage/html/index.html`.

**Крэши:** не найдено (ожидаемо для зрелого, давно поддерживаемого проекта
за ограниченное время фаззинга).

## Обоснование выбора фаззера

AFLNet выбран как coverage-guided, state-aware фаззер сетевых протоколов
(в отличие от Peach, требующего ручного описания грамматики протокола).
AFLNet — де-факто стандарт в академических работах по протокольному
фаззингу (использовался в оригинальной статье StateAFL как baseline),
имеет открытый, документированный механизм расширения под новые протоколы,
чем мы и воспользовались.
