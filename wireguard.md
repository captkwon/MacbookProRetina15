Wireguard 설치
- 와이어가드 설치 및 커널 드라이버 확인
```
# 1. 와이어가드 패키지 설치
sudo apt update && sudo apt install -y wireguard

# 2. 커널 모듈이 정상적으로 로드되었는지 확인 (아무 메시지도 안 뜨면 정상)
sudo modprobe wireguard
```

- 서버용 암호화 키 쌍(Private / Public Key) 생성 (서버가 사용할 비밀키와 공개키를 명령어로 한 번에 생성)
```
# 1. 와이어가드 설정 폴더로 이동 및 권한 보안 강화
sudo -i
cd /etc/wireguard
umask 077

# 2. 서버의 비밀키(privatekey)와 공개키(publickey)를 생성
wg genkey | tee privatekey | wg pubkey | tee publickey
```

- 생성된 키 값 확인하기 (이 값들은 추후 구성 파일을 만들 때 사용)
```
# 서버 비밀키 확인 (절대 외부에 노출 금지)
cat /etc/wireguard/privatekey

# 서버 공개키 확인 (클라이언트 기기에 등록할 키)
cat /etc/wireguard/publickey
```

- 설정 파일 생성(wg0.conf)
```
cat wg0.conf
[Interface]
PrivateKey = [cat privatekey]
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
# 첫 번째 스마트폰
PublicKey = [cat phone_publickey]
AllowedIPs = 10.0.0.2/32

[Peer]
# 두 번째 노트북
PublicKey = [cat mbp_publickey]
AllowedIPs = 10.0.0.3/32
```

- 단말 설정
```
# 1. 스마트폰 전용 비밀키와 공개키 발급
wg genkey | tee phone_privatekey | wg pubkey | tee phone_publickey

# 2. 스마트폰 전용 설정 파일 편집기 열기
cat phone.conf
[Interface]
PrivateKey = [cat_phone_privatekey]
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = [cat_publickey]
Endpoint = [내_외부_공인IP_또는_도메인]:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

- QR 발행
```
# QR코드 생성 도구 설치
$apt install -y qrencode
# QR코드 발행
qrencode -t ansiutf8 < phone.conf
```

- 서버를 라우터로 동작하여 내부 망 접속 허용
```
# 1. 패킷 중계 기능 즉시 켜기(취소시 forward=0)
sudo sysctl -w net.ipv4.ip_forward=1

# 2. 유선 랜 카드를 통한 주소 변환(NAT) 규칙 추가 (인터페이스 이름 확인) (취소시 -A 대신 -D)
sudo iptables -t nat -A POSTROUTING -o enp0s10 -j MASQUERADE

# 3. 방화벽 UFW 라우팅 허용 (취소시 allow 대신 delete allow)
sudo ufw route allow in on wg0
sudo ufw route delete allow in on wg0

# 방화벽 조회
sudo iptables -t nat -L -n -v
```

- Wireguard 실행 및 취소
wg-quick up wg0
