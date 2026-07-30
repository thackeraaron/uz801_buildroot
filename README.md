# uz801_buildroot
UZ801 Buildroot Config

This is the buildroot board config and scripts used in:

- https://www.youtube.com/watch?v=hwog0eWwG3c

This project is WIP so things might not work as expected.

Remember to take a copy of the firmware running on your device first before you do anything:

```
edl rf flash_backup.img

mkdir -p original
edl rl original
```


Project setup and build steps:

```
apt-get install file wget cpio unzip rsync bc git build-essential libssl-dev gcc-arm-none-eabi device-tree-compiler android-sdk-libsparse-utils gcc-aarch64-linux-gnu gcc-arm-none-eabi python3-cryptography python3-pyasn1-modules python3-pycryptodome fdisk

git clone https://github.com/buildroot/buildroot

cp -r src/* buildroot/*

cd buildroot

make uz801_defconfig

make -j32

./board/uz801/build_bootloader.sh
sudo ./board/uz801/make_flashable.sh
```

Reflash the new firmware (MAKE SURE YOU HAVE A BACKUP):

```
edl e boot
edl w aboot output/flashable/aboot.mbn
edl reset

fastboot flash partitions output/flashable/gpt.bin

fastboot flash boot output/flashable/boot.bin
fastboot flash rootfs output/flashable/rootfs.bin
fastboot flash aboot output/flashable/aboot.mbn
fastboot flash hyp output/flashable/hyp.mbn

fastboot flash rpm dragonboard/rpm.mbn
fastboot flash sbl1 dragonboard/sbl1.mbn
fastboot flash tz dragonboard/tz.mbn

fastboot flash fsc original/fsc.bin
fastboot flash fsg original/fsg.bin
fastboot flash modem original/modem.bin
fastboot flash modemst1 original/modemst1.bin
fastboot flash modemst2 original/modemst2.bin
fastboot flash persist original/persist.bin
fastboot flash sec original/sec.bin

fastboot reboot

```
