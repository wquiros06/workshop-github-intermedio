# Checklist previo

## Una semana antes

- [ ] Corre el laboratorio completo, de principio a fin, en un repositorio
      nuevo y limpio. No en el tuyo de la vez pasada. Los ejercicios 05 y 06
      dependen del estado del repositorio y solo se prueban de verdad desde
      cero.
- [ ] Verifica que las versiones de las acciones siguen vigentes. Suben de major
      con frecuencia, sobre todo por cambios de runtime de Node. Revisa
      `actions/checkout`, `actions/setup-dotnet`, `actions/upload-artifact` y
      `actions/download-artifact` en el marketplace y actualiza los YAML si hace
      falta. Este repositorio incluye `.github/dependabot.yml` para que las PRs
      lleguen solas.
- [ ] Confirma que el proyecto compila con el SDK que vas a pedir. El
      `TargetFramework` es `net9.0`. .NET 9 llega a fin de soporte el 10 de
      noviembre de 2026, junto con .NET 8. Si vas a impartir esto después de esa
      fecha, migra el proyecto a .NET 10 LTS y **prueba** que las pruebas pasan
      con las versiones de xunit y Microsoft.NET.Test.Sdk que trae el csproj.
- [ ] Decide público o privado según el plan de la audiencia, y ajusta el
      ejercicio 00 si es necesario.

## 48 horas antes

- [ ] Manda a los participantes el enlace a `laboratorio/00-preparacion.md` y
      pídeles que lo completen antes de la sesión.
- [ ] Pide explícitamente que corran `bash scripts/verificar-entorno.sh` y
      reporten fallas por adelantado.
- [ ] Si trabajas con una organización, valida que Actions esté habilitado, que
      los participantes puedan crear repositorios, y que no haya una política de
      acciones permitidas que bloquee `actions/*`.

## El día

- [ ] Prueba tu conexión y el compartir pantalla. La pestaña Actions tiene texto
      pequeño; aumenta el zoom del navegador a 150%.
- [ ] Ten abierta en pestañas separadas: la pestaña Actions de tu repositorio de
      demostración, Settings > Rules, y `soluciones/`.
- [ ] Anuncia al inicio los tres avisos que ahorran más tiempo:
      las ramas deben llamarse `lab/algo`; el repositorio va público; en el
      ejercicio 05, `Required approvals` va en 0 si trabajan solos.

## Después

- [ ] Recolecta en qué ejercicio se quedó cada quien. Es la señal más útil para
      recalibrar tiempos la próxima vez.
- [ ] Manda el enlace a `laboratorio/07-extras.md` para quien quiera seguir.

## Riesgos conocidos del entorno

| Riesgo | Mitigación |
|--------|------------|
| La organización tiene una política de acciones permitidas | Verifica en Settings > Actions > General que `actions/*` esté en la lista |
| Proxy corporativo bloquea nuget.org | Codespaces evita el problema, o prepara un `NuGet.Config` con el feed interno |
| Los participantes no pueden crear repositorios públicos | Créalos tú por adelantado, o consigue la excepción de política |
| Codespaces deshabilitado en la organización | Camino B del ejercicio 00, con verificación previa obligatoria |
| Alguien llega sin GitHub CLI | Todos los pasos tienen equivalente en la interfaz web, pero es más lento. Insiste en la preparación previa |
