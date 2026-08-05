# deploy-web.ps1
# Clean and compile Flutter Web App
Write-Host "Cleaning build files..." -ForegroundColor Cyan
flutter clean

Write-Host "Running flutter build web..." -ForegroundColor Cyan
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Copying vercel config files..." -ForegroundColor Cyan
# Ensure vercel.json is in build/web
Copy-Item -Path vercel.json -Destination build/web/vercel.json -Force

# Copy the .vercel config folder if it exists
if (Test-Path -Path .vercel) {
    Remove-Item -Path build/web/.vercel -Recurse -ErrorAction SilentlyContinue
    Copy-Item -Path .vercel -Destination build/web -Recurse -Force
}

Write-Host "Deploying build/web folder to Vercel..." -ForegroundColor Cyan
cd build/web
npx vercel --prod --yes
cd ../..

Write-Host "Deployment completed!" -ForegroundColor Green
