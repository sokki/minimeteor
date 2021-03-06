#!/bin/sh

# Install build tools
echo [minimeteor] Installing build tools
apt-get -qq update
apt-get -y install curl procps python g++ make sudo >/dev/null

# Create non-root user
useradd -m user
sudo -u user cp -r /app /home/user/
rm -rf /home/user/app/.meteor/local
rm -rf /home/user/app/node_modules
cd /home/user/app

# Setup auth for private npm modules
if [ -n $NPM_TOKEN ]
then
  echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >> .npmrc
fi

# Install Meteor
echo [minimeteor] Installing Meteor
sudo -u user curl "https://install.meteor.com/" | sh

# Install NPM packages
echo [minimeteor] Installing NPM dependencies
sudo -u user meteor npm install

# Build Meteor app
echo [minimeteor] Building Meteor app
sudo -u user meteor build --directory /home/user/meteor-app

# Install NPM packages in the bundle
echo [minimeteor] Install bundle NPM dependencies
cd /home/user/meteor-app/bundle/programs/server
sudo -u user meteor npm install

# Copy Node.js executable from Meteor distribution
cp `sudo -u user meteor node -e "console.log(process.argv[0]);"` ./

# Remove Meteor
echo [minimeteor] Cleaning up
rm -rf /home/user/app
rm /usr/local/bin/meteor
rm -rf ~/.meteor
rm -rf /home/user/.meteor
rm -rf /tmp

# Remove build tools and empty cache
apt-get -y --purge autoremove curl procps python g++ make
apt-get -y clean
rm -rf /var/lib/apt/lists/*
