# mdm-removal-script
Say goodbye to MDM!


This script is for noobs and requires you to install brew on your mac from https://brew.sh/.
After you install brew you can then run 'brew install usbmuxd'. Now you can follow these steps.
1. On your mac, open terminal and run 'iproxy 4444 44'
2. Run 'ssh -p 44 root@localhost' and authenticate with the password as 'alpine'
3. Run 'wget https://raw.githubusercontent.com/ChazzaH014/mdm-removal-script/main/mdmremoval.sh'
4. Run './mdmremoval.sh'
5. Profit? 

Your device should reboot and youll be greeted with setup again, proceed as normal and you should see no more MDM. :)
