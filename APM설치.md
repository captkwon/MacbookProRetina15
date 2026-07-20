# 패키지 설치
```
sudo apt update

sudo apt install \
    apache2 \
    mariadb-server \
    mariadb-client \
    php \
    libapache2-mod-php \
    php-cli \
    php-mysql \
    php-apcu \
    php-curl
    php-gd \
    php-intl \
    php-mbstring \
    php-xml

```
| 기존 기능                                          | 새 서버 패키지             |
| ---------------------------------------------- | -------------------- |
| Apache                                         | `apache2`            |
| MariaDB 서버                                     | `mariadb-server`     |
| MariaDB 명령행 클라이언트                              | `mariadb-client`     |
| PHP 기본                                         | `php`                |
| Apache에서 PHP 실행                                | `libapache2-mod-php` |
| PHP 명령행 실행                                     | `php-cli`            |
| `mysqli`, `pdo_mysql`, `mysqlnd`               | `php-mysql`          |
| APCu 캐시                                        | `php-apcu`           |
| 이미지 처리                                         | `php-gd`             |
| 국제화 기능                                         | `php-intl`           |
| 다국어 문자열                                        | `php-mbstring`       |
| XML, DOM, SimpleXML, XMLReader, XMLWriter, XSL | `php-xml`            |


### php-curl
- PHP에서 다른 웹서버나 API에 HTTP 요청을 보내는 기능이다.
- 예:
  - curl_init()
  - curl_setopt()
  - curl_exec()
- 사용 사례:
  - REST API 호출
  - 외부 서버에서 JSON 가져오기
  - 문자·결제·지도 API 사용
  - 다른 웹사이트에 파일 전송
  - OAuth 인증
  - Composer가 외부 패키지를 내려받을 때 활용
- PHP에서 외부 HTTP 요청을 전혀 하지 않는다면 필요 없다. 다만 범용성이 높고 용량 부담도 작으므로 설치해도 좋다.
```
sudo apt install php-curl
```

### php-zip
- PHP 코드에서 ZIP 압축파일을 읽거나 생성하는 기능이다.
- 예:
  - $zip = new ZipArchive();
  - $zip->open('backup.zip');
- 사용 사례:
  - 여러 파일을 ZIP으로 다운로드
  - 사용자가 올린 ZIP 압축 해제
  - Excel .xlsx 파일 처리
  - 일부 문서 라이브러리
  - Composer 패키지 압축 처리
- 단순 웹페이지와 DB 작업만 한다면 필요 없다. 운영체제의 zip, unzip 명령과는 별개다. php-zip은 PHP 프로그램 내부에서 ZIP을 처리할 때 필요하다.

##
2. sudo a2enmod headers rewrite ssl

a2enmod는 Ubuntu/Debian에서 제공하는 Apache 모듈 활성화 명령이다.

이름을 풀면:

a2      = Apache 2
en      = enable
mod     = module

즉:

a2enmod = Apache 2 module enable

반대 명령은:

sudo a2dismod 모듈명

이다.

실제로 무슨 일을 하나

Apache 모듈 설정은 보통 여기에 존재한다.

/etc/apache2/mods-available/

활성화된 모듈은 여기에 심볼릭 링크가 만들어진다.

/etc/apache2/mods-enabled/

예를 들어:

sudo a2enmod rewrite

를 실행하면 대략 다음 링크가 생성된다.

/etc/apache2/mods-enabled/rewrite.load
    → /etc/apache2/mods-available/rewrite.load

즉, 프로그램을 새로 설치하는 명령이라기보다 이미 설치된 Apache 기능을 설정상 활성화하는 명령이다. 이미 활성화되어 있어도 오류 없이 “이미 활성화됨” 정도로 끝난다.

모듈의 의미
sudo a2enmod headers rewrite ssl

은 한 번에 세 가지를 활성화한다.

headers: HTTP 응답 헤더 추가·변경
rewrite: URL 변환, 리다이렉트, .htaccess RewriteRule
ssl: HTTPS/TLS 지원

명령을 실행해도 현재 실행 중인 Apache 프로세스에는 즉시 반영되지 않는다. 일반적으로 다음 재시작 또는 reload 때 적용된다.

sudo systemctl restart apache2

다만 현재는 이 세 모듈을 모두 급하게 활성화할 필요는 없다.

기존 서버에서 활성화되어 있었으므로 동일하게 맞추려는 목적에서는 실행해도 된다. 그러나 실제 설정 이전 전에는 모듈만 켜져 있고 사용되지 않는 상태일 수 있다.

실행해도 안전하다.

sudo a2enmod headers rewrite ssl

실행 결과는 대략 다음처럼 나온다.

Enabling module headers.
Enabling module rewrite.
Enabling module ssl.
To activate the new configuration, you need to run:
  systemctl restart apache2

활성화 확인:

apache2ctl -M | grep -E 'headers|rewrite|ssl'

3. sudo systemctl enable --now apache2 mariadb

이 명령은 Apache와 MariaDB에 두 가지 작업을 동시에 한다.

enable = 컴퓨터를 부팅할 때 자동 시작하도록 등록
--now  = 등록만 하지 말고 지금도 즉시 시작

따라서:

sudo systemctl enable --now apache2 mariadb

는 사실상 다음 네 작업을 한 줄로 수행한다.

sudo systemctl enable apache2
sudo systemctl enable mariadb
sudo systemctl start apache2
sudo systemctl start mariadb

systemctl은 Ubuntu의 서비스 관리자 systemd를 제어하는 명령이다. --now를 enable과 함께 사용하면 부팅 시 자동 시작 설정과 현재 서비스 시작을 함께 수행한다.

다만 패키지 설치 과정에서 Apache와 MariaDB가 이미 자동 시작되었을 가능성이 높다.

현재 상태부터 확인해도 된다.

systemctl is-active apache2
systemctl is-active mariadb

둘 다 다음처럼 나오면 이미 실행 중이다.

active

자동 시작 여부:

systemctl is-enabled apache2
systemctl is-enabled mariadb

둘 다 다음이면 이미 설정되어 있다.

enabled

이미 둘 다 active, enabled라면 굳이 다시 실행할 필요는 없다. 실행해도 문제는 없다.

4. sudo apache2ctl configtest

이 명령은 Apache 설정파일의 문법 검사만 한다.

확인 범위는 대략 다음과 같다.

/etc/apache2/apache2.conf
/etc/apache2/ports.conf
/etc/apache2/mods-enabled/*
/etc/apache2/conf-enabled/*
/etc/apache2/sites-enabled/*

정상일 때:

Syntax OK

문제가 있으면 파일명과 줄 번호를 알려준다.

AH00526: Syntax error on line ...

이 명령은 Apache를 재시작하거나 설정을 적용하지 않는다. 설정을 읽어서 문법적으로 시작 가능한지만 검사한다. Apache 공식 문서에서도 configtest는 설정파일을 파싱해 Syntax OK 또는 구체적인 오류를 출력하는 검사라고 설명한다.

따라서 설정 변경 후에는 보통 이렇게 한다.

sudo apache2ctl configtest
sudo systemctl reload apache2

configtest가 실패하면 reload하지 않는 것이다.
