set -x 
mkdir app
cd app
git clone https://github.com/Guy-Davidson/Parking.git .
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y awscli
sudo apt-get install -y npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
npm i
node index.js
exit