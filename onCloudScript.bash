sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y npm
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
mkdir app
cd app
git init
git pull https://github.com/Guy-Davidson/Parking.git
npm i
node index.js
exit