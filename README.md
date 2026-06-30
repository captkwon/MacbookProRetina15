# MacbookProRetina 13" early2015 이용 루분투 서버 만들기
# OS설치 준비
- 파일 다운로드
- 부팅 USB 만들기
```
$ diskutil list
/dev/disk0 (internal, physical):
/dev/disk3 (synthesized):
/dev/disk4 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *31.5 GB    disk4
   1:             Windows_FAT_32 ROCKY-9-5-X             31.5 GB    disk4s1
$ diskutil unmountDisk /dev/disk4
Unmount of all volumes on disk4 was successful
$ ls *.iso
lubuntu-26.04-desktop-amd64.iso
$ sudo dd if=lubuntu-26.04-desktop-amd64.iso of=/dev/rdisk4 bs=1m
Password:
3736+1 records in
3736+1 records out
3918290944 bytes transferred in 346.117089 secs (11320709 bytes/sec)
$ diskutil eject /dev/disk4
Disk /dev/disk4 ejected
```
- 시스템 종료 후 Option + 전원 키 눌러 USB로 부팅
- 부팅후 데스크탑 기본 설정
-- 파란 제비 단추 - 기본 설정(Preferences) - LXQt 설정 - 세션 설정 (Session Settings)
-- 환경 변수 메뉴 추가 (Add): QT_SCALE_FACTOR, Value: 2 (화면 전체를 정확히 200% 확대하겠다는 뜻입니다. 1.5배를 원하시면 1.5 입력)
```
$ sudo apt-add-repository restricted --no-update
$ sudo apt install intel-microcode firmware-b43-installer --no-install-recommends -y
$ sudo apt-add-repository --remove restricted --no-update
$ sudo apt update && sudo apt upgrade --with-new-pkgs -y

$ sudo apt install openssh-server --no-install-recommends -y   // ssh 설치 및 open
$ sudo systemctl enable ssh && sudo systemctl start ssh
$ ip a
-- 여기까지 ssh 설치, 항상 시작, ip확인
$ sudo systemctl set-default multi-user.target  // 부팅시 TUI 사용
$ sudo reboot
---
$ sudo dpkg-reconfigure console-setup   // 본체 인코딩 설정+글꼴 16*32가 적절
$ sudo apt install fbterm fonts-nanum --no-install-recommends -y
$ sudo usermod -aG video $USER
$ sudo chmod u+s /usr/bin/fbterm
$ vi ~/.fbtermrc // font 종류와 사이즈 변경
$ fbterm   // 반드시 본체에서 수행
// gui실행
$ startx
$ sudo poweroff or sudo shutdown 0h now

```
