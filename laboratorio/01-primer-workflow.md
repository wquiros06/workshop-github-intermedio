# 01. Tu primer workflow

**Tiempo:** 15 minutos.

## Qué vas a lograr

Ejecutar un workflow a mano desde la pestaña Actions, leer sus logs y entender
qué significa cada línea del YAML. Nada más. No compilamos nada todavía.

## Contexto

GitHub Actions no es magia ni un lenguaje nuevo. Es esto: cuando pasa algo en
tu repositorio, GitHub prende una máquina virtual, clona lo que le digas y
corre los comandos que le pongas. Todo lo demás son detalles.

El archivo ya está en tu repositorio, en
`.github/workflows/00-hola-actions.yml`. Ábrelo y léelo antes de ejecutarlo.

## Paso 1: la anatomía

```yaml
name: 00 - Hola Actions          # el nombre que verás en la pestaña Actions

on:
  workflow_dispatch:             # cuándo corre. Aquí: solo cuando le des clic

permissions: {}                  # qué puede hacer este workflow en tu repo

jobs:
  saludo:                        # identificador del job (lo usarás en `needs`)
    name: Saludo                 # el nombre visible
    runs-on: ubuntu-latest       # en qué máquina corre
    steps:                       # los pasos, en orden
      - name: Imprimir un mensaje
        run: echo "Hola desde GitHub Actions"
```

Cuatro conceptos, y ya está:

**`on`** es el disparador. `workflow_dispatch` significa manual. Los que vas a
usar en la vida real son `push` y `pull_request`, y llegan en el ejercicio 02.

**`runs-on`** es la máquina. `ubuntu-latest` es una VM limpia que GitHub crea,
usa y destruye. Nada persiste entre runs, y nada persiste entre jobs.

**`steps`** son los pasos. Cada paso es una de dos cosas:
- `run:` ejecuta un comando de shell.
- `uses:` ejecuta una acción, que es código reutilizable que alguien más
  publicó. `actions/checkout@v7` es "el repositorio `actions/checkout`, versión
  v7".

**`permissions`** define qué puede hacer el token automático que GitHub le
inyecta al job. Aquí está vacío porque este workflow no toca el repositorio.
Es el mismo principio de mínimo privilegio que aplicas en cualquier otro lado.

## Paso 2: ejecutarlo

1. Ve a tu repositorio en GitHub, pestaña **Actions**.
2. En la lista de la izquierda, selecciona **00 - Hola Actions**.
3. Botón **Run workflow** a la derecha, deja la rama en `main`, clic en
   **Run workflow**.
4. Refresca. Aparece un run nuevo. Ábrelo.
5. Clic en el job **Saludo**. Se despliegan los pasos.

Expande cada paso y lee los logs. Fíjate en dos pasos que tú no escribiste:
**Set up job** y **Complete job**. Los agrega GitHub. En **Set up job** puedes
ver la imagen exacta del runner y los permisos que recibió el token.

## Paso 3: el mismo run desde la terminal

```bash
gh workflow run "00 - Hola Actions"

# Espera unos segundos y lista los runs
gh run list --workflow="00 - Hola Actions"

# Ver el detalle del último
gh run view --log
```

Vas a usar `gh run` el resto del workshop. Es más rápido que refrescar el
navegador.

## Paso 4: rómpelo a propósito

Edita `.github/workflows/00-hola-actions.yml` y cambia `runs-on: ubuntu-latest`
por `runs-on: ubuntu-latests`. Haz commit y push a `main`, y vuelve a
ejecutarlo manualmente.

```bash
git add .github/workflows/00-hola-actions.yml
git commit -m "romper el runner a proposito"
git push
gh workflow run "00 - Hola Actions"
```

El run va a quedar en espera y luego fallar. Lee el mensaje: GitHub no encuentra
un runner con esa etiqueta. Ahora deshazlo:

```bash
git revert --no-edit HEAD
git push
```

Este error, un typo en la etiqueta del runner, es el más común de todos y no
produce un error de sintaxis. El editor no te avisa. Solo se ve al ejecutar.

## Cómo sabes que terminaste

- Tienes al menos un run verde de **00 - Hola Actions**.
- Tienes un run rojo, el que rompiste a propósito.
- En la pestaña **Summary** del run verde ves la tabla que escribió el último
  paso con `$GITHUB_STEP_SUMMARY`.

## Cuando algo falla

| Síntoma | Qué pasó |
|---------|----------|
| No aparece el botón **Run workflow** | El workflow debe existir en la rama por defecto y tener `workflow_dispatch` en `on`. Verifica que hiciste push a `main`. |
| No aparece nada en la pestaña Actions | Actions está deshabilitado en el repositorio. Settings > Actions > General > Allow all actions. |
| El run queda "Queued" para siempre | Etiqueta de runner inválida, o tu organización tiene runners restringidos. |
| `gh workflow run` no encuentra el workflow | Usa el nombre exacto entre comillas, o el nombre del archivo: `gh workflow run 00-hola-actions.yml`. |

## Antes de continuar

Responde estas dos, sin ver el archivo:

1. ¿Qué diferencia hay entre `run:` y `uses:`?
2. Si un paso escribe un archivo en el runner, ¿el siguiente paso lo ve? ¿Y el
   siguiente job?

La respuesta a la segunda es la razón por la que existen los artefactos, que es
justo el ejercicio 03.
