#!/bin/sh -e
BR_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
IMAGES_DIR="$BR_DIR/output/images"
OUT_DIR="$BR_DIR/output/flashable"

KERNEL="$IMAGES_DIR/Image"
DTB="$IMAGES_DIR/msm8916-yiming-uz801v3.dtb"
ROOTFS_TAR="$IMAGES_DIR/rootfs.tar"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Must be run as root (needed for mount)" >&2
    exit 1
fi

for f in "$KERNEL" "$DTB" "$ROOTFS_TAR"; do
    [ -f "$f" ] || { echo "ERROR: Missing: $f" >&2; exit 1; }
done

for cmd in mkfs.ext2 mkfs.ext4 img2simg; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: Missing tool: $cmd" >&2; exit 1; }
done

rm -f "$OUT_DIR/boot.raw" "$OUT_DIR/rootfs.raw"
mkdir -p "$OUT_DIR" mnt

cleanup() {
    umount mnt 2>/dev/null || true
    rm -f "$OUT_DIR/boot.raw" "$OUT_DIR/rootfs.raw"
    rmdir mnt 2>/dev/null || true
}
trap cleanup EXIT

truncate -s 62914560 "$OUT_DIR/boot.raw"
mkfs.ext2 "$OUT_DIR/boot.raw"
mount "$OUT_DIR/boot.raw" mnt
mkdir -p mnt/extlinux mnt/dtbs/qcom
cp "$KERNEL" mnt/vmlinuz
cp "$DTB"    mnt/dtbs/qcom/
cat > mnt/extlinux/extlinux.conf << 'EOF'
default l0

label l0
    linux /vmlinuz
    fdt /dtbs/qcom/msm8916-yiming-uz801v3.dtb
    append earlycon root=PARTUUID=92b64350-0792-4a41-a7e6-c47ba2b1c2bb console=ttyMSM0,115200 no_framebuffer=true rw rootwait
EOF
umount mnt

truncate -s 536870912 "$OUT_DIR/rootfs.raw"
mkfs.ext4 "$OUT_DIR/rootfs.raw"
mount "$OUT_DIR/rootfs.raw" mnt
tar xpf "$ROOTFS_TAR" -C mnt
umount mnt

img2simg "$OUT_DIR/boot.raw"   "$OUT_DIR/boot.bin"
img2simg "$OUT_DIR/rootfs.raw" "$OUT_DIR/rootfs.bin"

rm -f "$OUT_DIR/boot.raw" "$OUT_DIR/rootfs.raw"
rmdir mnt 2>/dev/null || true
trap - EXIT

echo "Finished"
echo "Images in $OUT_DIR"
