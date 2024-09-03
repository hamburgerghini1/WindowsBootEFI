# use Windows repair disc to run Startup Repair

# update grub config file for EFI system
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg # Fedora
sudo update-grub # Ubuntu

# if grub doesn't find Windows Boot Manager
# find EFI partition (could be on sdb, sdc, etc if you have more than one hard drive)
gdisk -l /dev/sda
 
# find UUID using EFI partition number from first step
blkid /dev/sda1

# copy Boot/EFI folder from Windows directory to Linux /boot/efi/EFI/Microsoft/Boot/
 
# osprober will find this if set in /etc/grub.d/40_custom
# replace 8BE6-E170 with your UUID
# change hd1,gpt1 and ahci1,gpt1 to match your hard drive (could be hd0,gpt1 if only one hard drive)
menuentry 'Windows Boot Manager (on /dev/sda1)' --class windows --class os $menuentry_id_option 'osprober-efi-8BE6-E170' {
    insmod part_gpt
    insmod fat
    set root='hd1,gpt1'
    if [ x$feature_platform_search_hint = xy ]; then
      search --no-floppy --fs-uuid --set=root --hint-bios=hd1,gpt1 --hint-efi=hd1,gpt1 --hint-baremetal=ahci1,gpt1  8BE6-E170
    else
      search --no-floppy --fs-uuid --set=root 8BE6-E170
    fi
    chainloader /dev/sda1@/EFI/Microsoft/Boot/bootmgfw.efi
}
 
# or try this if the first one doesn't work
menuentry 'Windows 10 Pro' {
    insmod part_gpt
    insmod fat
    insmod search_fs_uuid
    insmod chain
    search --fs_uuid --no-floppy --set=root 8BE6-E170
    chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
}

# update grub config file for EFI system
# Fedora
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
# Ubuntu
sudo update-grub

# use efi boot manager to clean up the boot list
efibootmgr