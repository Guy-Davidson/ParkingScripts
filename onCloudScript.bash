sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y nodejs
sudo apt-get install -y npm
mkdir app
cd app
git init
git pull https://github.com/Guy-Davidson/Parking.git
npm i
node index.js
exit