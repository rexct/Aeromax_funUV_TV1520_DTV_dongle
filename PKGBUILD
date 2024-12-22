# Maintainer: Rexct Chen (rexct) <rexct1@gmail.com>

pkgname=funuv-tv
pkgver=6.12.4.arch1
pkgrel=1
pkgdesc='FunUV DTV USB Dongle Driver'
url='https://github.com/archlinux/linux'
arch=(x86_64)
license=(GPL-2.0-only)
makedepends=(
  bc
  cpio
  gettext
  libelf
  pahole
  perl
  python
  tar
  xz

  # htmldocs
  graphviz
  imagemagick
  python-sphinx
  python-yaml
  texlive-latexextra
)
options=(
  !strip
)
#install=funuv_dtv.install
_srcname=linux-${pkgver%.*}
_srctag=v${pkgver%.*}-${pkgver##*.}
source=(
  https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x/${_srcname}.tar.{xz,sign}
  $url/releases/download/$_srctag/linux-$_srctag.patch.zst{,.sig}
  config  # the main kernel config file
)
validpgpkeys=(
  ABAF11C65A2970B130ABE3C479BE3E4300411886  # Linus Torvalds
  647F28654894E3BD457199BE38DBBDC86092693E  # Greg Kroah-Hartman
  83BC8889351B5DEBBB68416EB8AC08600F108CDF  # Jan Alexander Steffens (heftig)
)
# https://www.kernel.org/pub/linux/kernel/v6.x/sha256sums.asc
sha256sums=('6f35f821433d8421be7167990747c7c4a0c451958fb96883446301af13d71152'
            'SKIP'
            '8d84f0e5f013c6c80cd2a2fe26da8e0c1170edc058f6f378e1261541781c12b9'
            'SKIP'
            'a6a234cd982d21f0d7daa3ba921293e450abd87ff5d7474d4a153b3f34cfabc5')
b2sums=('5f0db13ed414b6221db1acb6019580e10533ecd1b596918230a6076ce433c75c154a3799bcdab48b1fbb2ff90e573f8cc879ae2d26677c560c6818fa37ce3c24'
        'SKIP'
        '3544c1e7dcf488d06c7411ebde2b9133cfd27d194f7b668784a756efc6ba5b48b237054c8404501dd6f6fb79945c570bef4cd29c314a16ad2dcb66ae48bbdbf2'
        'SKIP'
        'fc60a774d8ba8a56b2397de7bb9908ae6e3ed733426a1b6a6574a11259f71559d77848cb4b43faf423d68c92c7fc4343be1eb1882a5f7d4e32065bf66f1e0753')

export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

prepare() {
  cd $_srcname

  #TV1520 DTV USB dongle
  sed -e 's.\/\* Vendor IDs \*\/.\/\* Vendor IDs \*\/\n#define USB_VID_FUNUV_TV_TV1520                 0x282d.g' -e 's.\/\* Product IDs \*\/.\/\* Product IDs \*\/\n#define USB_PID_FUNUV_TV_TV1520                         0x0608.g' -i include/media/dvb-usb-ids.h

  sed 's.RTL2832U devices: \*\/.RTL2832U devices: \*\/\n        { DVB_USB_DEVICE(USB_VID_FUNUV_TV_TV1520, USB_PID_FUNUV_TV_TV1520,\&rtl28xxu_props, "Funuv TV TV1520", NULL) },.g' -i drivers/media/usb/dvb-usb-v2/rtl28xxu.c

  echo "Setting version..."
  echo "-$pkgrel" > localversion.10-pkgrel
#  echo "${pkgbase#linux}" > localversion.20-pkgname

  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    src="${src%.zst}"
    [[ $src = *.patch ]] || continue
    echo "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  echo "Setting config..."
  #cp ../config .config
  zcat /proc/config.gz > .config
  make olddefconfig
  diff -u ../config .config || :

  make -s kernelrelease > version
  echo "Prepared $pkgbase version $(<version)"

  make EXTRAVERSION=-arch1 modules_prepare
  cp /usr/lib/modules/`uname -r`/build/Module.symvers ./

  cp /sys/kernel/btf/vmlinux ./
}

build() {
  cd $_srcname
  make -j8 M=drivers/media/usb/dvb-usb-v2
  zstd drivers/media/usb/dvb-usb-v2/dvb-usb-rtl28xxu.ko
}

package() {
  kgdesc="The $pkgdesc modules"
  depends=(
    coreutils
    initramfs
    kmod
  )
  optdepends=(
    'linux-firmware: firmware images needed for some devices'
  )
  provides=(
  )
  replaces=(
  )

  cd $_srcname
  local modulesdir="$pkgdir/usr/lib/modules/$(<version)"

  echo "Installing modules..."

  _extradir="/usr/lib/modules/$(</usr/src/linux/version)/updates"
  mkdir -p ${pkgdir}${_extradir}
  install -Dt "${pkgdir}${_extradir}" -m644 drivers/media/usb/dvb-usb-v2/dvb-usb-rtl28xxu.ko.zst
}

# vim:set ts=8 sts=2 sw=2 et:
