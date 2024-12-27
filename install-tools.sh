gem uninstall charlock_holmes
gem uninstall github-linguist
pacman -Rns icu icu-devel mingw-w64-x86_64-icu
pacman -Syu
pacman -S icu
pacman -S icu-devel
pacman -S mingw-w64-x86_64-icu
gem install charlock_holmes
gem install github-linguist
gem pristine --all
