sudo mkdir /mnt/intsausncfs01
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/intsausncfs01.cred" ]; then
    sudo bash -c 'echo "username=intsausncfs01" >> /etc/smbcredentials/intsausncfs01.cred'
    sudo bash -c 'echo "password=i1zfBhX+WI4whFVdt4Xzyq2baDFIAsdds6k28Vo/4Ys8mRq3CIHBsfqc/E1p8Ln8VvMbG4eScV/5tokFCTAxpg==" >> /etc/smbcredentials/intsausncfs01.cred'
fi
sudo chmod 600 /etc/smbcredentials/intsausncfs01.cred

sudo bash -c 'echo "//intsausncfs01.file.core.windows.net/hcm /mnt/intsausncfs01 cifs nofail,vers=3.0,credentials=/etc/smbcredentials/intsausncfs01.cred,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab'
sudo mount -t cifs //intsausncfs01.file.core.windows.net/hcm /mnt/intsausncfs01 -o vers=3.0,credentials=/etc/smbcredentials/intsausncfs01.cred,dir_mode=0777,file_mode=0777,serverino
