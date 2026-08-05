#!/bin/bash
# deploy-web.sh

echo -e "\033[0;36mCleaning build files...\033[0m"
flutter clean

echo -e "\033[0;36mRunning flutter build web...\033[0m"
flutter build web --release

if [ $? -ne 0 ]; then
    echo -e "\033[0;31mFlutter build failed!\033[0m"
    exit 1
fi

echo -e "\033[0;36mCopying vercel config files...\033[0m"
# Copy vercel.json into the build output
cp vercel.json build/web/vercel.json

# Copy .vercel config folder if it exists
if [ -d ".vercel" ]; then
    rm -rf build/web/.vercel
    cp -r .vercel build/web/
fi

echo -e "\033[0;36mDeploying build/web folder to Vercel...\033[0m"
cd build/web
npx vercel --prod --yes
cd ../..

echo -e "\033[0;32mDeployment completed!\033[0m"
