#########################################
#    Arch Linux Installation Script     #
#  Created by theparadoxxdev on GitHub  #
#########################################

echo "/---------------------------------------\ "
echo "|    Arch Linux Installation Script     |"
echo "|  Created by theparadoxxdev on GitHub  |"
echo "\---------------------------------------/"
echo 

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "!!!FAILED!!! This script must be run as root. (No sudo?)" 
   exit 1
fi

echo "##### Script has root access #####"
echo 
echo 
echo "This script is intended to install the BARE MINIMUM system to boot into Arch Linux."
echo "Any additional packages (ie. a DE) will be need to be installed seperately."
echo "This is NOT an official script, and comes with NO WARRANTY."
echo 
echo "An internet connection is required to install Arch Linux. The script will now confirm internet connectivity..."
echo 


# Check if we can establish an HTTPS connection to Google. Using HTTPS to confirm that there are no captive portals or transparent proxies in the way.
if nc -zw1 google.com 443; then
  echo "##### Internet is reachable #####"
  echo 
  else 
  echo "!!!FAILED!!! Unable to reach the internet. Please check your internet connection and try to run this script again."
  echo "(This can also occur due to a captive portal or transparent proxy server being in the way)"
  echo "(Wifi can be configured using iwctl)"
  echo 
  exit 1
fi

echo "A few things before we start:"
echo 
echo "1) Ensure you know the disk identifier of the drive you want to install Arch Linux on (ie. nvme0n1, sda, etc.)."
echo 
echo "2) It is assumed you are using the EN_US region and a US keyboard."
echo 
echo "3) It is assumed you are booted in UEFI mode."
echo 
echo "4) This script will use the GRUB bootloader, and will NOT set up secure boot, as there's too many variables involded in setting it up."
echo "   If you want to set up secure boot, there's very good documentation on the Arch Linux Wiki on how to do so."
read -p "Press ENTER when ready."
echo 
echo 
echo 
echo 
lsblk
echo 
# Enter the drive identifier and store it in a variable named driveid
read -p "Enter the drive identifier you would like to use: " driveid
echo $driveid
read -p "Is this correct? (y/n) " yesno
while [ $yesno = "n" ];
do
    read -p "Enter the drive identifier you would like to use: " driveid
    echo $driveid
    read -p "Is this correct? (y/n) " yesno
done

echo 
echo 
echo "Script will use /dev/"$driveid" as OS drive."
echo 
echo 

# A few questions before using parted to partition the drive

while true;
do
# Ask if the user wants swap space
read -p "Do you want swap space? (y/n) " swapyn
# If the user wants swap space, then ask how big they want the swap to be in GB 
if [[ $swapyn == "y" ]] && grep -q "nvme" <<< $driveid ; then
  read -p "How big do you want your swap space to be? (in GB) " swapsize
  echo "Swap space will be "$swapsize"GB in size and will be created at /dev/"$driveid"p2"
  echo "##### Drive Layout #####"
  echo 
  echo "/-------------------------------------------------------\ "
  echo "|     Partition           Size            Mountpoint    |"
  echo "\-------------------------------------------------------/"  
  echo "   /dev/"$driveid"p1          1GB                /boot"
  echo "   /dev/"$driveid"p2          "$swapsize"GB                swap"
  echo "   /dev/"$driveid"p3      Rest of drive          /"
  echo   
  echo
  echo
  read -p "Does the above look correct? (y/n) " driveok
  break
elif [[ $swapyn == "y" ]] && grep -q "sd" <<< $driveid ; then
  read -p "How big do you want your swap space to be? (in GB) " swapsize
  echo "Swap space will be "$swapsize"GB in size and will be created at /dev/"$driveid"2"
  break
else
  echo "!!!Invalid response!!!"
  continue
fi
# Confirm drive partitioning 
if [[ $swapyn == "y" ]] && grep -q "nvme" <<< $driveid ; then
echo "##### Drive Layout #####"
echo 
echo "/-------------------------------------------------------\ "
echo "|     Partition           Size            Mountpoint    |"
echo "\-------------------------------------------------------/"
echo "   /dev/"$driveid"p1          1GB                /boot"
echo "   /dev/"$driveid"p2          "$swapsize"GB                swap"
echo "   /dev/"$driveid"p3      Rest of drive          /"
echo
echo
echo
read -p "Does the above look correct? (y/n) " driveok
fi
if [[ $swapyn == "n" ]] && grep -q "nvme" <<< $driveid ; then
echo "##### Drive Layout #####"
echo 
echo "/-------------------------------------------------------\ "
echo "|     Partition           Size            Mountpoint    |"
echo "\-------------------------------------------------------/"
echo "   /dev/"$driveid"p1          1GB                /boot"
echo "   /dev/"$driveid"p2      Rest of drive          /"
echo
echo
echo
read -p "Does the above look correct? (y/n) " driveok
fi
if [[ $swapyn == "y" ]] && grep -q "sd" <<< $driveid ; then
echo "##### Drive Layout #####"
echo 
echo "/-------------------------------------------------------\ "
echo "|     Partition           Size            Mountpoint    |"
echo "\-------------------------------------------------------/"
echo "   /dev/"$driveid"1          1GB                  /boot"
echo "   /dev/"$driveid"2          "$swapsize"GB                  swap"
echo "   /dev/"$driveid"3      Rest of drive            /"
echo
echo
echo
read -p "Does the above look correct? (y/n) " driveok
fi

if $driveok == "y"; then
  break
fi

done
