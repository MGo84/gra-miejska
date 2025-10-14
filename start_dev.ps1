#!/usr/bin/env pwsh
Write-Host "🚀 Startuję środowisko developerskie..."

# Start backend (FastAPI)
Write-Host "👉 Uruchamiam backend (FastAPI)..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $(Get-Location)\backend; python -m uvicorn main:app --reload"

# Start panel admina (Next.js)
Write-Host "👉 Uruchamiam panel admina (Next.js)..."
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $(Get-Location)\panel-admina; npm run dev"

Write-Host "✅ Wszystko odpalone! Backend na http://127.0.0.1:8000, panel admina na http://localhost:3000"

