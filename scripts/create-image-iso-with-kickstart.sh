#!/bin/bash
# For more information please visit: https://access.redhat.com/solutions/60959

read -p "Input absolute path to the iso image file: " iso_image_file

mkdir /tmp/dvd

mount -o loop $iso_image_file /tmp/dvd || exit $?

read -p "Input an absolute path where to create a file directory for iso image files: " iso_image_files_dir

mkdir -p $iso_image_files_dir || exit $?

shopt -s dotglob

cp -avRf /tmp/dvd/* $iso_image_files_dir || exit $?

read -p "Select all kickstart files from $HOME/img-creation-files/ks-files to include into the image (separate with space) : " kickstart

cd $HOME/img-creation-files/ks-files/

cp $kickstart $iso_image_files_dir || exit $?

cd $iso_image_files_dir || exit $?

read -p "Select directory under /root/img-creation-files/ from which to copy modified grub files: " grub_dir

cp /root/img-creation-files/$grub_dir/isolinux/isolinux.cfg $iso_image_files_dir/isolinux/isolinux.cfg || exit $?
cp /root/img-creation-files/$grub_dir/EFI/BOOT/grub.cfg $iso_image_files_dir/EFI/BOOT/grub.cfg || exit $?

label=$(egrep -o "LABEL=\S*" $iso_image_files_dir/isolinux/isolinux.cfg | head -1 | cut -d= -f2) || exit $?

read -p "Choose a name for the new iso image file: " new_iso_name 

mkisofs -o /tmp/$new_iso_name -b isolinux/isolinux.bin -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "$label" . || exit $?

isohybrid --uefi /tmp/$new_iso_name

echo "Your new iso: /tmp/$new_iso_name"

umount /tmp/dvd

rmdir /tmp/dvd

rm -rf $iso_image_files_dir
