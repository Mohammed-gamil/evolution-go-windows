# Evolution GO - Build Script for Windows

$APP_NAME = "evolution-go"
$MAIN_PATH = "cmd\evolution-go\main.go"
$BUILD_DIR = "build"
$VERSION = "v0.0.0"

# Try to get version from VERSION file
if (Test-Path "VERSION") {
    $VERSION = Get-Content "VERSION"
}

$LDFLAGS = "-X main.version=$VERSION"
$GOFLAGS = "-v"

function Show-Help {
    Write-Host "Uso: .\build.ps1 [target]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alvos disponíveis:"
    Write-Host "  dev      - Roda a aplicação em modo desenvolvimento"
    Write-Host "  run      - Roda a aplicação em modo produção"
    Write-Host "  build    - Compila a aplicação para Windows"
    Write-Host "  clean    - Remove arquivos de build"
    Write-Host "  setup    - Instala dependências e gera swagger"
    Write-Host "  test     - Roda todos os testes"
}

$target = $args[0]
if ($null -eq $target) {
    Show-Help
    exit
}

switch ($target) {
    "dev" {
        Write-Host "🚀 Rodando Evolution GO em modo desenvolvimento..." -ForegroundColor Green
        go run -ldflags $LDFLAGS $MAIN_PATH -dev
    }
    "run" {
        Write-Host "🚀 Rodando Evolution GO..." -ForegroundColor Green
        go run $MAIN_PATH
    }
    "build" {
        Write-Host "🔨 Compilando $APP_NAME..." -ForegroundColor Green
        if (!(Test-Path $BUILD_DIR)) {
            New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
        }
        go build $GOFLAGS -ldflags $LDFLAGS -o "$BUILD_DIR\$APP_NAME.exe" $MAIN_PATH
        Write-Host "✅ Build completo: $BUILD_DIR\$APP_NAME.exe" -ForegroundColor Green
    }
    "clean" {
        Write-Host "🧹 Limpando arquivos de build..." -ForegroundColor Yellow
        if (Test-Path $BUILD_DIR) {
            Remove-Item -Recurse -Force $BUILD_DIR
        }
        if (Test-Path "coverage.out") { Remove-Item "coverage.out" }
        if (Test-Path "coverage.html") { Remove-Item "coverage.html" }
        Write-Host "✅ Limpeza completa" -ForegroundColor Green
    }
    "setup" {
        Write-Host "📦 Instalando dependências..." -ForegroundColor Green
        go mod download
        go mod verify
        Write-Host "📚 Gerando documentação Swagger..." -ForegroundColor Green
        if (Get-Command "swag" -ErrorAction SilentlyContinue) {
            swag init -g $MAIN_PATH -o .\docs
            Write-Host "✅ Swagger gerado com sucesso" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Swag não instalado. Instale com: go install github.com/swaggo/swag/cmd/swag@latest" -ForegroundColor Yellow
        }
        Write-Host "🎉 Setup completo!" -ForegroundColor Green
    }
    "test" {
        Write-Host "🧪 Rodando testes..." -ForegroundColor Green
        go test -v ./...
    }
    default {
        Write-Host "❌ Alvo desconhecido: $target" -ForegroundColor Red
        Show-Help
    }
}
