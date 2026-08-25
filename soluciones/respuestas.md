# Respuestas

No abras esto antes de intentar los ejercicios. Sabes que no sirve de nada.

---

## Workflow roto (ejercicio 04, parte B)

Archivo: `laboratorio/recursos/workflow-roto.yml`
Corregido: `soluciones/workflow-roto-corregido.yml`

### Error 1: `branch` en lugar de `branches`

```yaml
on:
  push:
    branch:        # incorrecto
      - main
```

La clave correcta es `branches`. GitHub no valida claves desconocidas dentro de
`push`, así que las ignora. El resultado es un `push:` sin filtro, que se
dispara en **todas** las ramas, no en ninguna. Peor que no dispararse: se
dispara donde no querías y quema minutos.

Corrección: `branches:`.

### Error 2: `ubuntu-latests`

```yaml
    runs-on: ubuntu-latests   # incorrecto
```

No existe esa etiqueta. El job entra en cola esperando un runner que nunca va a
aparecer, y expira después de un tiempo. No hay error de sintaxis, no hay
advertencia en el editor.

Corrección: `ubuntu-latest`.

Las etiquetas válidas de runners hospedados están en la
[documentación de runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).

### Error 3: `needs: compilar` apuntando a un job inexistente

```yaml
  test:
    needs: compilar    # el job se llama `build`
```

`needs` referencia el **identificador** del job, la llave del YAML, no el
`name:` visible. Este sí produce un error de validación y el run falla de
inmediato. Es el más fácil de los cuatro.

Corrección: `needs: build`.

### Error 4: la ruta del artefacto no coincide

```yaml
      - run: dotnet test --results-directory ./resultados
      - uses: actions/upload-artifact@v7
        with:
          path: ./TestResults      # no es donde escribió dotnet test
```

`dotnet test` escribió en `./resultados` y la acción intenta subir
`./TestResults`.

Este es el peligroso. Con el valor por default de `if-no-files-found` (que es
`warn`), la acción solo deja una advertencia en el log. **El job termina en
verde** y el artefacto queda vacío. Alguien descubre el problema semanas después,
cuando necesita el reporte y no está.

Corrección: `path: ./resultados`. Y como cinturón de seguridad,
`if-no-files-found: error`.

---

## Preguntas de los ejercicios

### 01, pregunta 1: diferencia entre `run:` y `uses:`

`run:` ejecuta un comando en el shell del runner. `uses:` invoca una acción, que
es código empaquetado que alguien publicó en un repositorio. Una acción puede
estar escrita en JavaScript, ser un contenedor Docker, o ser una composición de
otros pasos.

### 01, pregunta 2: qué comparte cada paso y cada job

Los **pasos** de un mismo job comparten el sistema de archivos del runner y el
directorio de trabajo. Un archivo escrito en un paso lo ve el siguiente.

Los **jobs** no comparten nada. Cada uno arranca en una máquina distinta. Para
pasar un valor de texto se usan `outputs`; para pasar archivos, artefactos.

### 04: por qué el error 4 es más peligroso que el error 3

El error 3 falla de inmediato y de forma visible. Lo arreglas en dos minutos.

El error 4 deja el pipeline en verde produciendo un artefacto vacío. Un pipeline
que miente sobre su propio resultado es peor que uno que falla, porque el equipo
construye confianza sobre algo que no está funcionando.

Regla general: prefiere que el pipeline falle ruidosamente a que pase en
silencio. `if-no-files-found: error` en lugar de `warn` es una aplicación de esa
regla.

---

## Estado final de los archivos

| Después del ejercicio | Archivo de referencia |
|-----------------------|-----------------------|
| 02 | `soluciones/02-ci.yml` |
| 03 | `soluciones/03-ci.yml` |
| 04 | `soluciones/04-ci.yml` |
| 06 | `soluciones/06-release.yml` |
| 07-A | `soluciones/07-packages.yml` |
| 07-B | `soluciones/08-matrix.yml` |
