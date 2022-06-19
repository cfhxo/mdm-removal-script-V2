# mdm-removal-script
Say goodbye to MDM!


This script is for noobs and requires you to install brew on your mac from https://brew.sh/, and jailbreak your phone with checkra1n from https://checkra.in/.
After you install brew you can then run `brew install usbmuxd`. Now you can follow these steps.

1. Jailbreak your iPhone with checkra1n.
2. On your mac, open terminal and run `iproxy 4444 44`
3. Run `ssh -p 44 root@localhost` and authenticate with the password as `alpine`
4. Run `wget https://raw.githubusercontent.com/ChazzaH014/mdm-removal-script/main/mdmremoval.sh`
5. Run `chmod 777 ./mdmremoval.sh`
6. Run `./mdmremoval.sh`
7. Profit? 

Your device should reboot and youll be greeted with setup again, proceed as normal and you should see no more MDM. :)
