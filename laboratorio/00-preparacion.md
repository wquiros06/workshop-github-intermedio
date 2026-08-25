# 00. Preparación

**Tiempo:** 10 minutos. Si tomas más, usa Codespaces y sigue adelante.

## Qué vas a lograr

Una copia propia de este repositorio, en tu cuenta, con el proyecto compilando
y las pruebas pasando.

## Antes de empezar: el repositorio va a ser público

Créalo **público**, no privado. No es un detalle de estilo, son dos límites
reales de la plataforma:

1. Los rulesets y las reglas de protección de rama solo están disponibles en
   repositorios públicos si tu cuenta es GitHub Free. En repositorios privados
   necesitas Pro, Team o Enterprise
   ([documentación](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository)).
   El ejercicio 05 depende de esto.
2. GitHub Actions con runners estándar es gratis y sin límite de minutos en
   repositorios públicos. En privados consumes tu cuota mensual, que en el plan
   Free son 2,000 minutos
   ([documentación](https://docs.github.com/en/actions/concepts/billing-and-usage)).

Si estás en una organización con Enterprise, puedes usar privado sin problema.
Confirma con tu instructor antes de decidir.

## Camino A: GitHub Codespaces (recomendado)

Cero instalación. El contenedor ya trae el SDK de .NET 9, GitHub CLI y las
extensiones de VS Code.

1. Entra al repositorio base y usa **Use this template > Create a new
   repository**.
2. Nómbralo `workshop-github-intermedio-TU_USUARIO` y márcalo **Public**.
3. En tu repositorio nuevo, botón **Code > Codespaces > Create codespace on
   main**.
4. Espera a que termine de construir. Cuando la terminal esté lista:

```bash
bash scripts/verificar-entorno.sh
```

Las cuentas Free incluyen horas de Codespaces al mes sin costo. Si te preocupa
el consumo, apaga el codespace al terminar desde `github.com/codespaces`.

## Camino B: tu máquina

Necesitas:

- SDK de .NET 9 ([descarga](https://dotnet.microsoft.com/download/dotnet/9.0))
- Git
- GitHub CLI ([instalación](https://cli.github.com))

```bash
# 1. Autenticarte
gh auth login

# 2. Crear tu repositorio a partir del template
#    Reemplaza TU_USUARIO
gh repo create TU_USUARIO/workshop-github-intermedio-TU_USUARIO \
  --template armandoblanco/workshop-github-intermedio \
  --public --clone

cd workshop-github-intermedio-TU_USUARIO

# 3. Verificar
bash scripts/verificar-entorno.sh
```

En Windows sin bash, corre los comandos de verificación a mano:

```powershell
dotnet restore
dotnet build --configuration Release --no-restore
dotnet test --configuration Release --no-build
```

## Cómo sabes que terminaste

El script imprime `Todo listo` y no hay ninguna línea `FALLA`. En particular,
`dotnet test` debe terminar con todas las pruebas pasando.

## Cuando algo falla

| Síntoma | Causa y salida |
|---------|----------------|
| `dotnet: command not found` | No tienes el SDK. Usa Codespaces en lugar de pelearte con la instalación durante la sesión. |
| `dotnet --version` dice 8.x | El proyecto apunta a `net9.0`. Un SDK 8 no lo compila. Instala el 9 o usa Codespaces. |
| `gh auth status` falla | Corre `gh auth login`, elige HTTPS y autenticación por navegador. |
| `--template` no funciona | Tu organización puede tenerlo deshabilitado. Clona el repo, borra `.git`, y sube el contenido a un repo nuevo tuyo. |
| El restore no baja paquetes | Proxy corporativo. Necesitas un `NuGet.Config` con la fuente interna de tu empresa. Este es un problema de red, no del workshop. |

## Nota sobre versiones

El proyecto apunta a .NET 9, que llega a fin de soporte el **10 de noviembre de
2026**, el mismo día que .NET 8
([anuncio de Microsoft](https://devblogs.microsoft.com/dotnet/dotnet-8-9-end-of-support/)).
Para el workshop no cambia nada. Para un proyecto real, el destino es .NET 10
LTS, con soporte hasta noviembre de 2028.
