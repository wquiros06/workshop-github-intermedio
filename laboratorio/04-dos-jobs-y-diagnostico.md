# 04. Dos jobs y diagnóstico

**Tiempo:** 20 minutos.

## Qué vas a lograr

Partir el pipeline en dos jobs conectados con `needs`, y encontrar cuatro
errores en un workflow roto sin ejecutarlo.

## Parte A: dos jobs (10 min)

### Contexto

Hasta ahora tienes un job con seis pasos. Un segundo job significa un segundo
runner: otra máquina, otro checkout, otro restore. Eso no es gratis.

Se justifica cuando:

- Los jobs pueden correr en paralelo y ganas tiempo de reloj.
- Necesitas condiciones distintas, por ejemplo desplegar solo si las pruebas
  pasaron y solo desde `main`.
- Necesitas permisos distintos. Un job que publica un paquete requiere
  `packages: write`, y no quieres darle ese permiso al job que compila.

No se justifica porque se vea más ordenado. Partir un pipeline lineal en cuatro
jobs secuenciales lo hace más lento y más caro sin ganar nada.

Aquí lo partimos por razones didácticas y para que veas el costo.

### Paso 1: separar build y test

Reemplaza el bloque `jobs:` de `.github/workflows/01-ci.yml` por el contenido
de `soluciones/04-ci.yml`, o edítalo tú siguiendo esta estructura:

```yaml
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    outputs:
      version-sdk: ${{ steps.sdk.outputs.dotnet-version }}
    steps:
      # checkout, setup-dotnet (con id: sdk), restore, build
      # y al final: subir bin/Release como artefacto "binarios"

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: build          # espera a build y solo corre si pasó
    steps:
      # checkout, setup-dotnet, download-artifact "binarios",
      # restore, test, subir resultados, resumen
```

Dos mecanismos nuevos:

**`needs: build`** crea la dependencia. Sin `needs`, los jobs corren en
paralelo. Con `needs`, `test` espera y además solo arranca si `build` terminó
en verde.

**`outputs`** pasa un valor de un job a otro. Los jobs están en máquinas
distintas, así que no comparten variables de entorno ni archivos. Un output es
una cadena de texto, nada más. Para archivos existen los artefactos.

Fíjate en el paso `Restaurar dependencias` dentro del job `test`, después de
bajar el artefacto. El artefacto trae `bin/` pero no `obj/`, y
`dotnet test --no-build` necesita `obj/project.assets.json` para resolver dónde
está el assembly. Sin ese restore, el job falla. Es exactamente el tipo de
detalle que hace que copiar un pipeline de internet no funcione.

### Paso 2: verificar

```bash
git add .github/workflows/01-ci.yml
git commit -m "ci: separar build y test en dos jobs"
git push
gh run watch
```

En el navegador, la vista del run ahora muestra un grafo con dos cajas y una
flecha. Compara el tiempo total contra el run anterior de un solo job. Debería
ser más lento. Esa diferencia es el costo de partir jobs.

## Parte B: el workflow roto (10 min)

### Contexto

Leer YAML de CI y encontrar el error sin ejecutarlo es una habilidad de uso
diario. La mayoría de los errores no son de sintaxis, así que el editor no te
avisa y solo aparecen cuando el run falla o, peor, cuando corre pero no hace lo
que crees.

### El ejercicio

Abre `laboratorio/recursos/workflow-roto.yml`. Tiene **4 errores
intencionales**. Todos son de configuración. Ninguno es un error de sintaxis
YAML, así que el archivo carga sin problema.

Anótalos en una lista antes de abrir la solución. Date 7 minutos.

Pistas, una por error, solo si te atoras:

<details>
<summary>Pista 1</summary>
Revisa el disparador. Hay una clave en singular que debería estar en plural.
Si la clave no existe, GitHub la ignora en silencio.
</details>

<details>
<summary>Pista 2</summary>
Lee la etiqueta del runner carácter por carácter.
</details>

<details>
<summary>Pista 3</summary>
El job `test` declara que depende de otro job. ¿Ese job existe con ese nombre?
</details>

<details>
<summary>Pista 4</summary>
Compara la carpeta donde `dotnet test` escribe los resultados contra la carpeta
que la acción de artefactos intenta subir.
</details>

Cuando termines, compara con `soluciones/respuestas.md`.

### Por qué estos cuatro

No son inventados. Son los que más aparecen en repositorios reales:

1. Una clave mal escrita en `on:` hace que el workflow simplemente nunca se
   dispare. No hay error, no hay run, no hay nada. La gente pierde horas
   buscando un problema de permisos que no existe.
2. Un typo en `runs-on` deja el job en cola indefinidamente hasta que expira.
3. Un `needs` a un job inexistente sí produce un error de validación, y es el
   más fácil de los cuatro.
4. Una ruta de artefacto que no coincide produce, con la configuración por
   default, solo una advertencia. El run queda verde y el artefacto vacío.

El cuarto es el peligroso, porque un pipeline verde que no produce nada es peor
que uno rojo.

## Cómo sabes que terminaste

- Tu pipeline corre con dos jobs y el grafo muestra la dependencia.
- Encontraste los 4 errores, o entendiste los que se te fueron.
- Puedes explicar por qué el error 4 es más peligroso que el error 3.

## Cuando algo falla

| Síntoma | Qué pasó |
|---------|----------|
| `Job 'test' depends on unknown job 'X'` | `needs` usa el identificador del job (la llave del YAML), no el `name:`. |
| El job `test` no encuentra los binarios | El artefacto se extrae en el directorio de trabajo respetando la estructura de rutas. Revisa con `run: find . -name '*.dll' \| head` en un paso temporal. |
| Los dos jobs corren en paralelo | Falta `needs`, o lo pusiste dentro de `steps:` en lugar de al nivel del job. |
| El output llega vacío | El paso que lo produce necesita un `id:`, y el output se declara a nivel de job, no de step. |
