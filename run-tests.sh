#!/bin/bash

# Função para selecionar e executar testes no Android
run_android_tests() {
  ANDROID_DEVICE_ID=$(adb devices | grep -w "device" | awk 'NR==1{print $1}')
  echo "Dispositivo Android encontrado: $ANDROID_DEVICE_ID"
  if [ -z "$ANDROID_DEVICE_ID" ]; then
    echo "Nenhum dispositivo Android conectado."
    adb devices
    exit 1
  fi
  /usr/local/bin/maestro test --format junit --output report-android.xml tests/android
}

# Função para selecionar e executar testes no iOS
run_ios_tests() {
  IOS_DEVICE_ID=$(xcrun simctl list devices | grep -w "Booted" | awk 'NR==1{print $1}')
  echo "Dispositivo iOS encontrado: $IOS_DEVICE_ID"
  if [ -z "$IOS_DEVICE_ID" ]; then
    echo "Nenhum simulador iOS em execução."
    xcrun simctl list devices
    exit 1
  fi
  /usr/local/bin/maestro test --format junit --output report-ios.xml tests/ios
}

# Perguntar ao usuário qual plataforma deseja testar
echo "Escolha a plataforma para executar os testes:"
echo "1) Android"
echo "2) iOS"
read -p "Digite o número da plataforma: " platform_choice

case $platform_choice in
  1)
    run_android_tests
    ;;
  2)
    run_ios_tests
    ;;
  *)
    echo "Opção inválida. Por favor, escolha 1 para Android ou 2 para iOS."
    exit 1
    ;;
esac

# Verificar se os relatórios foram gerados
if [ "$platform_choice" -eq 1 ]; then
  if [ ! -f "report-android.xml" ]; then
    echo "Falha ao gerar o relatório do Android"
    exit 1
  fi
  platform="android"
else
  if [ ! -f "report-ios.xml" ]; then
    echo "Falha ao gerar o relatório do iOS"
    exit 1
  fi
  platform="ios"
fi

# Converter relatórios XML para HTML
npm run generate-html-report $platform
