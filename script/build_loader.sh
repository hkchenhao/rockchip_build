#!/bin/bash -e

cd ../../loader
./tools/boot_merger ./RKBOOT/RK3399MINIALL.ini
./tools/trust_merger ./RKTRUST/RK3399TRUST.ini
mv rk3399_loader_*.bin ../build/image/loader.bin
mv trust.img ../build/image/trust.img
cd -