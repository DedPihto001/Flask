$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI is not installed or is not available on PATH."
}

$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot

try {
    docker compose up -d --build
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose failed to build or start the application."
    }

    $baseUrl = "http://localhost:5000"
    $deadline = (Get-Date).AddSeconds(30)
    $ready = $false

    while ((Get-Date) -lt $deadline) {
        try {
            $null = Invoke-WebRequest -UseBasicParsing -Uri $baseUrl -TimeoutSec 3
            $ready = $true
            break
        }
        catch [System.Net.WebException] {
            Start-Sleep -Seconds 1
        }
    }

    if (-not $ready) {
        docker compose logs --no-color
        throw "The Flask service did not respond at $baseUrl within 30 seconds."
    }

    $checks = @(
        @{ path = "/"; expected = '{"message":"Hello from Flask!"}' },
        @{ path = "/info"; expected = '{"app":"Flask Docker Demo","version":"1.0.0"}' },
        @{ path = "/calc/7/5"; expected = '{"a":7,"b":5,"sum":12}' }
    )
    $results = foreach ($check in $checks) {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl$($check.path)"
        if ($response.StatusCode -ne 200) {
            throw "$($check.path) returned HTTP $($response.StatusCode)."
        }

        $data = $response.Content | ConvertFrom-Json
        $actual = $data | ConvertTo-Json -Compress
        if ($actual -ne $check.expected) {
            throw "$($check.path) returned unexpected JSON: $actual"
        }

        [ordered]@{
            path       = $check.path
            statusCode = $response.StatusCode
            response   = $data
        }
    }

    $report = [ordered]@{
        runtime     = "Docker Compose"
        checkedAt   = (Get-Date).ToString("o")
        baseUrl     = $baseUrl
        checks      = @($results)
    }
    $outputPath = Join-Path $PSScriptRoot "docker-results.json"
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $outputPath -Encoding UTF8
    Write-Output "All Docker endpoint checks passed. Results saved to $outputPath"
}
finally {
    Pop-Location
}
