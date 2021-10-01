#!/bin/bash 

#################################################
# https://github.com/furkun/LinuxHostsGenerator #
#################################################

rm -rf hosts-files
mkdir hosts-files
rm -f hosts hosts.tmp

if [[ ! -f "hosts-sources.txt" ]]; then
    echo "hosts-sources.txt doesn't exist."
    exit
fi

echo "----- Hosts files are downloading..."
wget --no-check-certificate -i hosts-sources.txt -P hosts-files

echo "-----All hosts files have been downloaded."
echo "-----Merging all hosts files..."

for f in hosts-files/*; do
    (cat "${f}"; echo) >> hosts.tmp
done

rm -rf hosts-files

echo "-----All hosts files have been merged."
echo "-----Compressing hosts file..."

sed -i 's/#.*$//;/^$/d' hosts.tmp
awk '!seen[$0]++' hosts.tmp > hosts
rm -f hosts.tmp
sed -i 's/  / /' hosts
sed -i 's/   / /' hosts
sed -i 's/    / /' hosts
sed -i 's/     / /' hosts
sed -i 's/	/ /' hosts

echo "-----hosts file is compressed."
sed -i '/127.0.0.1 localhost/d' hosts
sed -i '/::1 ip6-localhost ip6-loopback/d' hosts
sed -i '/fe00::0 ip6-localnet/d' hosts
sed -i '/ff00::0 ip6-mcastprefix/d' hosts
sed -i '/ff02::1 ip6-allnodes/d' hosts
sed -i '/ff02::2 ip6-allrouters/d' hosts
sed -i '/::1 localhost/d' hosts
sed -i 's/127.0.0.1/0.0.0.0/' hosts
echo "#This hosts file is created with LinuxHostsGenerator\n#https://github.com/furkun/LinuxHostsGenerator\n\n\n\n127.0.0.1	localhost\n127.0.1.1	$(hostname)\n::1     ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\n\n$(cat hosts)" > hosts
echo "-----hosts file is generated. ✓"

read -p "Do you want to update your hosts file? (y/n)" CONT
if [[ "$CONT" = "y" ]]; then
    sudo mv /etc/hosts.bak /etc/hosts.bak.bak
    sudo mv /etc/hosts /etc/hosts.bak
    sudo cp hosts /etc/hosts
    echo "-----hosts file is updated. ✓"
fi

read -p "Do you want to clear your dns cache? (y/n)" CONT
if [[ "$CONT" = "y" ]]; then
    sudo /etc/init.d/nscd restart
    sudo systemd-resolve --flush-caches
    echo "-----Your DNS cache is cleared. ✓"
fi
