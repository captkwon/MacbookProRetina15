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
- 
