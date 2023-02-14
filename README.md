# ArchLinux-KDE-Plasma-setup-script
A script that automates the etire process of setting up the full KDE plasma desktop env with some additional apps and tweaks to make it more usable for my usecase.

### Some pre requisites

* Please make sure to enable multilib repository before running this script
  * https://wiki.archlinux.org/title/official_repositories#Enabling_multilib
* run this command `sudo pacman -Syyuu wget`
* after it finishes make sure to reboot before running the script and after running it
* DO NOT RUN AS SUDO/ROOT

### Script variables
Please make sure to adjust for your system before running the script. I have tested in a VM so here is what the variables looked like for me

```bash
function main {
    ### VARS
    pass="test"
    username="test"
    gpudriver="amd"
    ...some more code down there
```
VARS
* pass - the users password or password for the root account in case use is not root user
* username - the users username or username for the root account in case use is not root user
* gpudriver - which GPU driver to install there are 3 options AMD or NVIDIA or INTEL and take one of these 3 inputs
  * amd - to install AMD open source drivers
  * nvidia - to install proprietary NVIDIA drivers
  * intel - to install INTEL open source drivers

### Some more script information
There are some sections where user input is expected so please make sure to read the prompts and when promped please be ready to use you accounts details to proceed.

### Troubleshooting
In case of any problems you could try rerunning the script more times just to be sure all got applied. If an error appears make sure to raise an Issue https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/issues with a lot of detail so that we can minize the amount of time required to fix issues.

---
BeanGreen247, 2023
