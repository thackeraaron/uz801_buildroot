#!/bin/sh -e
# builds hyp.mbn, aboot.mbn and gpt.bin for the UZ801

BR_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SRC_DIR="$BR_DIR/board/uz801/src"
OUT_DIR="$BR_DIR/output/flashable"

mkdir -p "$SRC_DIR" "$OUT_DIR"

if [ ! -d "$SRC_DIR/qhypstub" ]; then
    git clone https://github.com/msm8916-mainline/qhypstub.git "$SRC_DIR/qhypstub"
fi
if [ ! -d "$SRC_DIR/lk2nd" ]; then
    git clone https://github.com/msm8916-mainline/lk2nd.git "$SRC_DIR/lk2nd"
fi
if [ ! -d "$SRC_DIR/qtestsign" ]; then
    git clone https://github.com/msm8916-mainline/qtestsign.git "$SRC_DIR/qtestsign"
fi

# qhypstub

echo ">>> Building qhypstub..."
make -C "$SRC_DIR/qhypstub" CROSS_COMPILE=aarch64-linux-gnu-

# lk2nd

echo ">>> Patching lk2nd for UZ801 MMC speed..."
grep -q "USE_TARGET_HS200_CAPS" "$SRC_DIR/lk2nd/project/lk1st-msm8916.mk" || \
    echo 'DEFINES += USE_TARGET_HS200_CAPS=1' >> "$SRC_DIR/lk2nd/project/lk1st-msm8916.mk"

echo ">>> Building lk2nd (lk1st-msm8916) for UZ801..."
make -C "$SRC_DIR/lk2nd" \
    LK2ND_BUNDLE_DTB="msm8916-512mb-mtp.dtb" \
    LK2ND_COMPATIBLE="yiming,uz801-v3" \
    TOOLCHAIN_PREFIX=arm-none-eabi- \
    lk1st-msm8916

# qtestsign

echo ">>> Signing hyp.mbn..."
"$SRC_DIR/qtestsign/qtestsign.py" hyp \
    "$SRC_DIR/qhypstub/qhypstub.elf" \
    -o "$OUT_DIR/hyp.mbn"

echo ">>> Signing aboot.mbn..."
"$SRC_DIR/qtestsign/qtestsign.py" aboot \
    "$SRC_DIR/lk2nd/build-lk1st-msm8916/emmc_appsboot.mbn" \
    -o "$OUT_DIR/aboot.mbn"

# create GPT partition

echo ">>> Creating GPT partition image..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

truncate -s 179323904 "$TMPDIR/gpt.img"

sfdisk "$TMPDIR/gpt.img" << 'EOF'
label: gpt
label-id: A7669581-A922-4E62-918B-E555E9F41822
unit: sectors
first-lba: 34
last-lba: 350208
sector-size: 512

gpt.img1  : start=      4096, size=        2, type=57B90A16-22C9-E33B-8F5D-0E81686A68CB, uuid=41266BB7-F886-44E2-A910-BD689792C135, name="fsc"
gpt.img2  : start=      4098, size=     3072, type=638FF8E2-22C9-E33B-8F5D-0E81686A68CB, uuid=93064C2C-10BC-47F8-9B95-472D3BB9F9D3, name="fsg"
gpt.img3  : start=      7170, size=   131072, type=EBD0A0A2-B9E5-4433-87C0-68B6B72699C7, uuid=B13CCF6C-E8BC-4823-8C45-5098CFF6CA16, name="modem"
gpt.img4  : start=    138242, size=     3072, type=EBBEADAF-22C9-E33B-8F5D-0E81686A68CB, uuid=B7F5F556-8A90-4BE4-A0A7-922A3C719322, name="modemst1"
gpt.img5  : start=    141314, size=     3072, type=0A288B1F-22C9-E33B-8F5D-0E81686A68CB, uuid=1F0C7F41-7AAE-4ED8-B822-F682550BE323, name="modemst2"
gpt.img6  : start=    144386, size=    65536, type=6C95E238-E343-4BA8-B489-8681ED22AD0B, uuid=2B904BB7-600E-4E58-8DEC-A9A9A20488E9, name="persist"
gpt.img7  : start=    209922, size=       32, type=303E6AC3-AF15-4C54-9E9B-D9A8FBECF401, uuid=935BC8F1-65EF-4EF6-8BAC-511D30E4C20A, name="sec"
gpt.img8  : start=    209954, size=     1024, type=E1A6A689-0C8D-4CC6-B4E8-55A4320FBD8A, uuid=74E3488C-BC2C-45DF-8A65-F42AC4A684D1, name="hyp"
gpt.img9  : start=    210978, size=     1024, type=098DF793-D712-413D-9D4E-89D711772228, uuid=753A7C12-60AD-4D24-B5BD-CC46CBC529AE, name="rpm"
gpt.img10 : start=    212002, size=     1024, type=DEA0BA2C-CBDD-4805-B4F9-F428251C3E98, uuid=DD5915DE-D222-4E65-8596-7D61A187C81D, name="sbl1"
gpt.img11 : start=    213026, size=     2048, type=A053AA7F-40B8-4B1C-BA08-2F68AC71A4F4, uuid=5B14569D-8E4C-4C21-9AA3-2B8C359E6876, name="tz"
gpt.img12 : start=    215074, size=     2048, type=400FFDCD-22E0-47E7-9A23-F16ED9382388, uuid=84D1F8E7-6828-4587-B53B-1DC2DCFDBBFC, name="aboot"
gpt.img13 : start=    217122, size=   131072, type=20117F86-E985-4357-B9EE-374BC1D8487D, uuid=BB03B505-E67B-481A-BB86-FCA9CB2B1043, name="boot"
gpt.img14 : start=    348194, size=     2015, type=1B81E7E6-F50D-419B-A739-2AEEF8DA3335, uuid=92B64350-0792-4A41-A7E6-C47BA2B1C2BB, name="rootfs"
EOF

dd if="$TMPDIR/gpt.img" of="$OUT_DIR/gpt.bin" bs=512 count=34
dd if="$TMPDIR/gpt.img" bs=512 skip=2      count=32 >> "$OUT_DIR/gpt.bin"
dd if="$TMPDIR/gpt.img" bs=512 skip=350241          >> "$OUT_DIR/gpt.bin"

echo ""
echo "Done! Built in: $OUT_DIR"
ls -lh "$OUT_DIR/gpt.bin" "$OUT_DIR/hyp.mbn" "$OUT_DIR/aboot.mbn"
