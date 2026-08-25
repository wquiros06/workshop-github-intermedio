#!/usr/bin/env bash
# Verificación previa al workshop. Ejecuta esto ANTES de la sesión.
# Si algo falla aquí, resuélvelo antes y no en los primeros diez minutos
# del laboratorio.

set -u
fallas=0

check() {
  local nombre="$1"; shift
  if "$@" > /dev/null 2>&1; then
    printf '  OK    %s\n' "$nombre"
  else
    printf '  FALLA %s\n' "$nombre"
    fallas=$((fallas + 1))
  fi
}

echo "Verificando herramientas"
check "git instalado"            git --version
check "dotnet instalado"         dotnet --version
check "gh (GitHub CLI) instalado" gh --version
check "gh autenticado"           gh auth status

echo
echo "Verificando el proyecto"
check "restore"                  dotnet restore
check "build"                    dotnet build --configuration Release --no-restore
check "test"                     dotnet test --configuration Release --no-build

echo
if [ "$fallas" -eq 0 ]; then
  echo "Todo listo. Puedes empezar el laboratorio 00."
  exit 0
fi

echo "$fallas verificación(es) fallaron. Revisa laboratorio/00-preparacion.md."
exit 1
