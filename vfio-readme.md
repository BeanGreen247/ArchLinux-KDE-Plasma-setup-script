Install packages
```
sudo pacman -S virt-manager qemu vde2 iptables-nft dnsmasq bridge-utils openbsd-netcat edk2-ovmf swtpm qemu qemu-block-gluster qemu-block-iscsi virt-manager libvirt ebtables dnsmasq bridge-utils
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl restart libvirtd
sudo virsh net-start default
sudo virsh net-autostart default
```
The install will ask to replace a tables package just say yes and you are good to go.

Make sure to reboot.

make sure iommu is enabled in your bios and do the following
```
sudo nano /etc/default/grub
```
from this `GRUB_CMDLINE_LINUX_DEFAULT="quiet resume=UUID=0ea1742a-d569-4102-8e73-bd6288da2591 loglevel=3"`

to this `GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on resume=UUID=0ea1742a-d569-4102-8e73-bd6288da2591 loglevel=3"`

basically we add `intel_iommu=on` if on intel or `amd_iommu=on` if on amd and add it between `quiet` and `resume=...`

save the file and run this

sudo grub-mkconfig -o /boot/grub/grub.cfg

then reboot

so run this code
```bash
#!/bin/bash
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

find your gpu, for me it is the RTX 3060 Ti

```
IOMMU Group 2:
        00:01.0 PCI bridge [0604]: Intel Corporation 6th-10th Gen Core Processor PCIe Controller (x16) [8086:1901] (rev 03)
        01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA104 [GeForce RTX 3060 Ti Lite Hash Rate] [10de:2489] (rev a1)
        01:00.1 Audio device [0403]: NVIDIA Corporation GA104 High Definition Audio Controller [10de:228b] (rev a1)
```


next take note of the ids in the brackets so these ones in my case
```
[10de:2489]
[10de:228b]
```

and add them to your grub.cfg as part of the vfio-pci.ids kernel parameter

like this `GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on vfio-pci.ids=10de:2489,10de:228b vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 iommu=pt resume=UUID=0ea1742a-d569-4102-8e73-bd6288da2591 loglevel=3"`

basically what we added after `intel_iommu=on` was `vfio-pci.ids=10de:2489,10de:228b vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 iommu=pt` where `vfio-pci.ids=10de:2489,10de:228b` contains the IDs we have taken note of before seperated by a comma

so after that do ctrl+s and ctrl+x

and run this command one more time
```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
next we need to adjust the loading order of modules, we need to do this for our gpu to be successfully hijacked
```
sudo nano /etc/mkinitcpio.conf
```
and find a line that says `modules` and type in like this in order, this is important
```
MODULES="vfio_pci vfio vfio_iommu_type1 vfio_virqfd"
```
next scroll until you find `hooks` and make sure that modconf is avaiable
```
HOOKS="base udev autodetect modconf block keyboard keymap consolefont resume filesystems fsck"
```
note: if `modconf` does not exist, then just write it in inbetween `autodetect` and `block` and it has to be in this order in order for this to work

after this hit ctrl+s and ctrl+x

and now we need to regenerate our kernel images
```
sudo mkinitcpio -P
```
then reboot, your display which was connected to the gpu should be blank after the reboot

next lauch virt manager it will ask for a root password so type it in

next create a new virtual machine

Steps on creating a VM in virtual machine manager

1. Pick Manual install
2. Choose the OS you are installing: Microsoft Windows 11 (win11)
3. RAM: 26624
4. CPUs: 10
5. Create a disk image for the VM: 256GiB (if you have a spare ssd you can pass it here)
6. Tick Customize config before install
7. make sure to select chiptset to be Q35 and secure boot firmware here, should be something like `UEFI x86_64: /usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd`
    * I should note that my Arch system does not have an EFI partition and yet it works under kVM
8. Select NIC and change Network source to Virtual network 'default' NAT
9. Click add Hardware and add storage
    select or create custom

    and paste in the drive from the /dev/disk/by-id/ dir

    in my case /dev/disk/by-id/ata-WDC_WD20EZBX-00AYRA0_WD-WXC2A71C5L58

    To find the drive that we want to pass

    run this commad
    ```
    sudo lshw -class disk -class storage
    ```
    and look for the disk to pass

    //to identify just look at he product name (so WDC WD20EZBX-00A in my case)
    ```
    *-disk:1
          description: ATA Disk
          product: WDC WD20EZBX-00A
          vendor: Western Digital
          physical id: 1
          bus info: scsi@2:0.0.0
          logical name: /dev/sdb
          version: 1A01
          serial: WD-WXC2A71C5L58
          size: 1863GiB (2TB)
          capabilities: gpt-1.00 partitioned partitioned:gpt
          configuration: ansiversion=5 guid=e625b1c9-7160-4c36-8d34-e4d258eb02eb logicalsectorsize=512 sectorsize=4096
    ```
    next oppen your file explorer and navigate to here `/dev/disk/by-id/`

    and look for the drive

    in my case `/dev/disk/by-id/ata-WDC_WD20EZBX-00AYRA0_WD-WXC2A71C5L58`

    there will be multiple seperated by parts and you need the one without "part" in its name so in my case `ata-WDC_WD20EZBX-00AYRA0_WD-WXC2A71C5L58`

    next copy its location and paste in into the select or create custom box as mention at the start

    next select Device type as Disk device and bus type as sata and click finish

    next add a SATA CDROM, click add hardware Select Storage and pick Device type as CDROM device and bus type as SATA and finally click finish

    now under source path click browse and then click browse local and pick the windows 10 install media (iso file)

    go into boot options and change the boot order with all drives and the cdrom selected

    with all that hit apply and click on the monitor icon and click on Power on virtual machine

so the vm is successfully created and the os is ready to be installed so install it normally

i will be getting a spare ssd at some point so i will reinstall windows onto the new ssd and pass it into the vm duh

once it is finished with the install you want to trun it off

next go into overview and click the xml tab

in here do the following

replace
```
<cpu mode="host-passthrough" check="none" migratable="on"/>
```
with
```
 <cpu mode="host-passthrough" check="none" migratable="on">
    <topology sockets="1" dies="1" cores="6" threads="2"/>
    <cache level="3" mode="emulate"/>
    <feature policy="disable" name="hypervisor"/>
    <feature policy="require" name="svm"/>
    <feature policy="require" name="invtsc"/>
    <feature policy="require" name="topoext"/>
  </cpu>
```
next find hyperv section with the features
```
<hyperv mode="custom">
 <relaxed state="on"/>
 <vapic state="on"/>
 <spinlocks state="on" retries="8191"/>
</hyperv>
```
and replace it with this below along with the features section
```
 <features>
    <acpi/>
    <apic/>
    <hyperv mode="custom">
      <relaxed state="on"/>
      <vapic state="on"/>
      <spinlocks state="on" retries="8191"/>
      <vpindex state="on"/>
      <runtime state="on"/>
      <synic state="on"/>
      <stimer state="on">
        <direct state="on"/>
      </stimer>
      <reset state="on"/>
      <vendor_id state="on" value="FckYouNVIDIA"/>
      <frequencies state="on"/>
      <reenlightenment state="on"/>
      <tlbflush state="on"/>
      <ipi state="on"/>
      <evmcs state="off"/>
    </hyperv>
    <kvm>
      <hidden state="on"/>
    </kvm>
    <vmport state="off"/>
    <smm state="on"/>
    <ioapic driver="kvm"/>
  </features>
```
next boot the vm up and let it update and while we are there go to control panel, add or remove programs and click on Turn windows features on or off and you want to tick Hyper-V and enable everything in Hyper-V there and click ok

make sure to apply all the updates by rebooting after it finishes make sure to check cpu stas and then power off

///at the top of the file change it to this
```
<domain xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0" type="kvm">
```
under devices add lookin glass at the end of devices section
```
<devices>
    ...
  <shmem name='looking-glass'>
    <model type='ivshmem-plain'/>
    <size unit='M'>32</size>
  </shmem>
</devices>
```

next create a config file for lookinglass `sudo nano /etc/tmpfiles.d/10-looking-glass.conf`
```
f	/dev/shm/looking-glass	0660	beangreen247	kvm	-
```
replace `beangreen247` with your username

next initialize the config file inside of systemd
```
sudo systemd-tmpfiles --create /etc/tmpfiles.d/10-looking-glass.conf
```

note: why lookinglass? has lower latency

also make sure to install it
```
yay -S looking-glass
```
once vm open go to link below and download and install the windows driver

link to driver to install on windows 10/11
* https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/upstream-virtio/

make sure to use the vfio-win-upstream one

and install lookinglass client for windows
* https://looking-glass.io/downloads

after that power off the vm and add your gpus

Add hardware and go PCI Host device and add both NVIDIA pci devices, so that would be `01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA104 [GeForce RTX 3060 Ti Lite Hash Rate] [10de:2489] (rev a1)` and `01:00.1 Audio device [0403]: NVIDIA Corporation GA104 High Definition Audio Controller [10de:228b] (rev a1)`

Permissions, quite important
```
sudo usermod -a -G libvirt,kvm,libvirt-qemu,input,disk,audio,video <some_user>
```
in my case
```
sudo usermod -a -G libvirt,kvm,libvirt-qemu,input,disk,audio,video beangreen247
sudo usermod -a -G libvirt,kvm,libvirt-qemu,input,disk,audio,video root
```
restart the libvirtd service in order to apply
```
sudo systemctl restart libvirtd
```
and this is what it looks like in the xml
```
  <vcpu placement="static">10</vcpu>
  <iothreads>4</iothreads>
  <cputune>
    <vcpupin vcpu="0" cpuset="1"/>
    <vcpupin vcpu="1" cpuset="2"/>
    <vcpupin vcpu="2" cpuset="3"/>
    <vcpupin vcpu="3" cpuset="4"/>
    <vcpupin vcpu="4" cpuset="5"/>
    <vcpupin vcpu="5" cpuset="7"/>
    <vcpupin vcpu="6" cpuset="8"/>
    <vcpupin vcpu="7" cpuset="9"/>
    <vcpupin vcpu="8" cpuset="10"/>
    <vcpupin vcpu="9" cpuset="11"/>
    <emulatorpin cpuset="0,6"/>
    <iothreadpin iothread="1" cpuset="0"/>
    <iothreadpin iothread="2" cpuset="6"/>
    <iothreadpin iothread="3" cpuset="0"/>
    <iothreadpin iothread="4" cpuset="0"/>
  </cputune>
```
You may need to change the XML based on your topology

now try and test it

```
sudo nano reassign-cpu.sh
```
```
pass="not_gonna_dox_myself"
echo $pass | sudo -S systemctl set-property --runtime -- system.slice AllowedCPUs=0-11
echo $pass | sudo -S systemctl set-property --runtime -- user.slice AllowedCPUs=0-11
echo $pass | sudo -S systemctl set-property --runtime -- init.scope AllowedCPUs=0-11
```

the script that we added at startup/on login will reassing cpu cores back to linux

to do that run it as follows `sudo bash reassign-cpu.sh`, this script should be run after powering down the VM as well to return all the cores to our Linux host

```
sudo nano unassign-cpu.sh
```
```
pass="not_gonna_dox_myself"
echo $pass | sudo -S systemctl set-property --runtime -- system.slice AllowedCPUs=1,7
echo $pass | sudo -S systemctl set-property --runtime -- user.slice AllowedCPUs=1,7
echo $pass | sudo -S systemctl set-property --runtime -- init.scope AllowedCPUs=1,7
```

this script will be launched before running the VM for optimal performance, leaving ounly 2 cores with our Linux env

keyboard and mouse passthrough time
```
|beangreen247@ElministerReborn [14:16:39] ~ branch:|
>>> ll /dev/input/by-id
total 0
drwxr-xr-x 2 root root 340 28. úno 15.08 ./
drwxr-xr-x 4 root root 720 28. úno 15.08 ../
lrwxrwxrwx 1 root root  10 28. úno 14.04 usb-Cherry_USB_keyboard-event-if01 -> ../event12
lrwxrwxrwx 1 root root  10 28. úno 14.04 usb-Cherry_USB_keyboard-event-kbd -> ../event10
lrwxrwxrwx 1 root root   9 28. úno 12.18 usb-KYE_Systems_Corp._FaceCam_1000X-event-if00 -> ../event5
lrwxrwxrwx 1 root root  10 28. úno 15.03 usb-LIZHI_Flash_IC_USB_Keyboard-event-if01 -> ../event24
lrwxrwxrwx 1 root root  10 28. úno 15.03 usb-LIZHI_Flash_IC_USB_Keyboard-event-kbd -> ../event22
lrwxrwxrwx 1 root root  10 28. úno 15.03 usb-LIZHI_Flash_IC_USB_Keyboard-if01-event-kbd -> ../event25
lrwxrwxrwx 1 root root  10 28. úno 15.03 usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_205B38863632-event-mouse -> ../event13
lrwxrwxrwx 1 root root  10 28. úno 15.03 usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_205B38863632-if01-event-kbd -> ../event14
lrwxrwxrwx 1 root root   9 28. úno 15.03 usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_205B38863632-mouse -> ../mouse2
lrwxrwxrwx 1 root root   9 28. úno 14.04 usb-Logitech_USB_Optical_Mouse-event-mouse -> ../event9
lrwxrwxrwx 1 root root   9 28. úno 14.04 usb-Logitech_USB_Optical_Mouse-mouse -> ../mouse1
lrwxrwxrwx 1 root root  10 28. úno 15.08 usb-ShanWan_Controller_XBOX_360_For_Windows-event-joystick -> ../event26
lrwxrwxrwx 1 root root   6 28. úno 15.08 usb-ShanWan_Controller_XBOX_360_For_Windows-joystick -> ../js0
lrwxrwxrwx 1 root root   9 28. úno 12.18 usb-XP-PEN_STAR_G640-if01-event-mouse -> ../event6
lrwxrwxrwx 1 root root   9 28. úno 12.18 usb-XP-PEN_STAR_G640-if01-mouse -> ../mouse0
```
look for your device and note it down

the following 2 commands return the envent##, so make sure to adjust based on your config
```
ll /dev/input/by-id | grep usb-LIZHI_Flash_IC_USB_Keyboard-event-kbd | awk {'print $10'} | cut -c 4-
ll /dev/input/by-id | grep usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_205B38863632-event-mouse | awk {'print $10'} | cut -c 4-
```
```
keyboardEventID=$(ll /dev/input/by-id | grep usb-LIZHI_Flash_IC_USB_Keyboard-event-kbd | awk {'print $10'} | cut -c 4-)
mouseEventID=$(ll /dev/input/by-id | grep usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_205B38863632-event-mouse | awk {'print $10'} | cut -c 4-)
```
these will then return our event nums for our devices
```
echo $keyboardEventID
echo $mouseEventID
```
we are looking for your keyboard and mouse specifically if you are are not sure which device is your keyboard: `cat /dev/input/by-id/usb-LIZHI_Flash_IC_USB_Keyboard-event-kbd` and press buttons on your keyboard, if characters of any sort appear, that is the proper device the same applies to your mouse, so `cat /dev/input/by-id/usb-Logitech_USB_Optical_Mouse-event-mouse` in my case

You can add `<input type='evdev'> <source dev='/dev/input/event1234' grab='all' repeat='on'/> </input>` to the XML for keyboards (of course change event1234 with your kbd event) and `<input type='evdev'> <source dev='/dev/input/event1234'/> </input>` for mice
* so for keyboard `<input type="evdev"> <source dev="/dev/input/event22"/> </input>`
* so for mouse `<input type="evdev">  <source dev="/dev/input/event9" grab="all" repeat="on"/> </input>`

so what we can do is put them into a nice little script to give us the updated eventIDs on startup

[kVMeventIDDialog.sh](https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/blob/main/kVMeventIDDialog.sh)

This cript will create a popup window on startup telling us what we need to change in our settings XML file for our keyboard and mouse to work

once in windows set the pooling rate to 125Hz to avoid stutters, if you can set it, most mice have a pooling rate of 125Hz by default anyway

next we need to edit the `/etc/libvirt/qemu.conf` file
```
sudo nano /etc/libvirt/qemu.conf
```
change `#user = "libvirt-qemu"` to `user = "beangreen247"`

replace `beangreen247` with your username of course

sudo systemctl restart libvirtd.service

next add these lines to the main xml
```
|beangreen247@ElministerReborn [22:08:04] ~ branch:|
>>> sudo mkdir /root/.config/
|beangreen247@ElministerReborn [22:08:13] ~ branch:|
>>> sudo mkdir /root/.config/pulse/
|beangreen247@ElministerReborn [22:08:17] ~ branch:|
>>> sudo cp -r /home/beangreen247/.config/pulse/cookie /root/.config/pulse/cookie
```
next add this at the start
```
<domain xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0" type="kvm">
```
and this at the end
```
  </devices>
  <qemu:commandline>
    <qemu:arg value="-device"/>
    <qemu:arg value="ich9-intel-hda,addr=1f.1"/>
    <qemu:arg value="-audiodev"/>
    <qemu:arg value="id=alsa,driver=vfio-pci"/>
  </qemu:commandline>
</domain>
```
find the audio driver
```
|beangreen247@ElministerReborn [18:35:34] ~ branch:|
>>> systemctl --user stop pipewire.socket
|beangreen247@ElministerReborn [18:36:43] ~ branch:|
>>> inxi -A
Audio:
  Device-1: Intel Comet Lake PCH-V cAVS driver: snd_hda_intel
  Device-2: NVIDIA GA104 High Definition Audio driver: vfio-pci
  Device-3: KYE Systems (Mouse Systems) FaceCam 1000X type: USB
    driver: snd-usb-audio,uvcvideo
  Sound API: ALSA v: k6.1.12-arch1-1 running: yes
  Sound Server-1: PulseAudio v: 16.1 running: yes
```

next spoofing our hardware

to get the information needed just install and use lshw

create the provision file `touch /home/beangreen247/provision.ign`

again replavce `beangreen247` with your username

add this to your XML file
```
<sysinfo type="smbios">
    <bios>
      <entry name="vendor">American Megatrends Inc.</entry>
      <entry name="version">A.40</entry>
      <entry name="date">09/10/2023</entry>
    </bios>
    <system>
      <entry name="manufacturer">ArchLinux</entry>
      <entry name="product">Virt-Manager</entry>
      <entry name="version">4.1.0</entry>
    </system>
    <baseBoard>
      <entry name="manufacturer">ASUS</entry>
      <entry name="product">TUF GAMING B460M-PLUS</entry>
      <entry name="version">Rev 1.xx</entry>
      <entry name="serial">200569104900493</entry>
    </baseBoard>
    <chassis>
      <entry name="manufacturer">SilentiumPC</entry>
      <entry name="version">SPC156</entry>
      <entry name="serial">SPC156</entry>
      <entry name="asset">Gladius M35W</entry>
      <entry name="sku">Pure Black</entry>
    </chassis>
    <oemStrings>
      <entry>myappname:some arbitrary data</entry>
      <entry>otherappname:more arbitrary data</entry>
    </oemStrings>
  </sysinfo>
  <sysinfo type="fwcfg">
    <entry name="opt/com.example/name">example value</entry>
    <entry name="opt/com.coreos/config" file="/home/beangreen247/provision.ign"/>
  </sysinfo>
  <os>
    <type arch="x86_64" machine="pc-q35-7.2">hvm</type>
    <loader readonly="yes" secure="yes" type="pflash">/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd</loader>
    <nvram>/var/lib/libvirt/qemu/nvram/win11_VARS.fd</nvram>
    <bootmenu enable="yes"/>
    <smbios mode="sysinfo"/>
  </os>
```
mention how to pass gamecontroller --TODO

incase the vm does not want to power down use the `powerDownAllVMs.sh` script that can be found in the scripts folder or in the folder where you have saved it
```
bash scripts/powerDownAllVMs.sh
```
the `powerDownAllVMs.sh` script can be found here [powerDownAllVMs.sh](https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/blob/main/powerDownAllVMs.sh)

and the full and final XML file is located here [settings.xml](https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/blob/main/settings.xml)

in windows we have to do some more changes in order for all the VM checks to pass, I was able to get most of them, but hey it works
