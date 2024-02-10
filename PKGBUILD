# Maintainer: Alex Gherman <aleksey.gherman@gmail.com>
pkgname='panetrie'
pkgver=1.0
pkgrel=1
pkgdesc='Config driven ALPM hook to synchronize Pacman and AUR installed package lists to a local directory.'
arch=('x86_64' 'i686')
license=('MIT')
depends=('pacman')
makedepends=('make')
url="https://github.com/alexgherman/${pkgname}.git"
source=("https://github.com/alexgherman/${pkgname}/archive/v${pkgver}.tar.gz")
sha256sums=('SKIP')

package() {
  cd "${srcdir}/${pkgname}-${pkgver}"
  make DESTDIR="${pkgdir}" install
}