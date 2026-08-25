# 03. Artefactos y resumen del run

**Tiempo:** 15 minutos.

## Qué vas a lograr

Que el pipeline produzca un archivo descargable con los resultados de las
pruebas, y una tabla legible en la pantalla de resumen del run.

## Contexto

El runner es desechable. Cuando el job termina, la máquina se destruye con todo
lo que había dentro. Si generaste un reporte y no lo sacaste, se perdió.

Un **artefacto** es un archivo o carpeta que subes desde el runner y queda
guardado en GitHub, descargable desde la interfaz o con `gh`. Es la forma
estándar de conservar reportes de cobertura, binarios, logs de pruebas y
resultados de escaneos.

El **step summary** es distinto: es Markdown que escribes a un archivo especial
y GitHub lo renderiza en la pantalla del run. Sirve para lo que la gente
necesita ver de un vistazo sin abrir logs.

## Paso 1: generar el reporte

`dotnet test` por default no deja archivo. Hay que pedírselo. Edita
`.github/workflows/01-ci.yml` y reemplaza el paso **Ejecutar pruebas**:

```yaml
      - name: Ejecutar pruebas
        run: |
          dotnet test \
            --configuration Release \
            --no-build \
            --logger "trx;LogFileName=resultados.trx" \
            --results-directory ./resultados
```

El `|` después de `run:` es YAML para "lo que sigue es texto de varias líneas".
Sin él, no puedes partir el comando.

## Paso 2: subir el artefacto

Agrega este paso justo después:

```yaml
      - name: Publicar resultados de pruebas
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: resultados-de-pruebas
          path: ./resultados
          retention-days: 5
          if-no-files-found: error
```

Tres decisiones que importan:

`if: always()` hace que el paso corra aunque las pruebas hayan fallado. Sin
esto, el job se detiene en el paso rojo y nunca subes el reporte, que es
precisamente cuando lo necesitas.

`retention-days: 5` en lugar del default de 90. El almacenamiento de artefactos
se cobra y comparte cuota con GitHub Packages. Un reporte de pruebas de hace
tres meses no le sirve a nadie.

`if-no-files-found: error` falla el paso si la ruta está vacía. El default es
`warn`, que te deja un artefacto vacío y la falsa sensación de que funcionó.

## Paso 3: el resumen

Agrega al final del job:

```yaml
      - name: Escribir el resumen del run
        if: always()
        run: |
          TRX=$(find ./resultados -name '*.trx' | head -1)
          TOTAL=$(grep -o 'total="[0-9]*"' "$TRX" | head -1 | grep -o '[0-9]*')
          PASADAS=$(grep -o 'passed="[0-9]*"' "$TRX" | head -1 | grep -o '[0-9]*')
          FALLIDAS=$(grep -o 'failed="[0-9]*"' "$TRX" | head -1 | grep -o '[0-9]*')
          {
            echo "### Resultado de las pruebas"
            echo ""
            echo "| Métrica | Valor |"
            echo "|---------|-------|"
            echo "| Total    | ${TOTAL:-0} |"
            echo "| Pasadas  | ${PASADAS:-0} |"
            echo "| Fallidas | ${FALLIDAS:-0} |"
          } >> "$GITHUB_STEP_SUMMARY"
```

`$GITHUB_STEP_SUMMARY` es una variable de entorno con la ruta a un archivo.
Todo lo que le escribas se renderiza como Markdown en la pestaña Summary del
run. No hay API ni acción de por medio, es escribir a un archivo.

Nota sobre el parsing: extraer números de un XML con `grep` es frágil y no lo
harías en producción. Aquí sirve para ver el mecanismo sin instalar
dependencias. En un pipeline real usarías una acción que ya sabe leer TRX o
JUnit y publica los resultados como check.

## Paso 4: probarlo

```bash
git add .github/workflows/01-ci.yml
git commit -m "ci: agregar artefactos y resumen"
git push
gh run watch
```

Cuando termine:

1. En el navegador, abre el run y mira la pestaña **Summary**. Arriba está la
   tabla, abajo la sección **Artifacts** con `resultados-de-pruebas`.
2. Desde la terminal:

```bash
gh run download --name resultados-de-pruebas --dir ./descarga
ls -R ./descarga
```

## Paso 5: comprobar el `if: always()`

Vuelve a meter la prueba que falla del ejercicio 02, haz push y confirma que
el artefacto **sí** se subió a pesar del job rojo. Luego revierte.

Si te saltas este paso te vas a creer que `if: always()` es decorativo. No lo
es.

## Cómo sabes que terminaste

- Descargaste el artefacto y contiene un archivo `.trx`.
- La pestaña Summary muestra la tabla con números reales, no ceros.
- Confirmaste que el artefacto se sube incluso cuando las pruebas fallan.

## Cuando algo falla

| Síntoma | Qué pasó |
|---------|----------|
| `No files were found with the provided path` | `--results-directory` y `path:` no coinciden. Deben apuntar al mismo lugar. |
| La tabla del summary sale con ceros | El `.trx` no se generó. Verifica que el `--logger "trx;..."` esté bien escrito, con las comillas. |
| `Artifact name is not valid` | El nombre no puede tener `/`, `\`, `:`, `<`, `>`, `"`, `|`, `*` ni `?`. |
| No puedo subir dos veces el mismo nombre | Correcto, desde la v4 de la acción los artefactos son inmutables. Usa nombres distintos. |
| El summary sale como texto plano | Falta la línea en blanco entre el encabezado y la tabla. Markdown la necesita. |

## Referencia

- [Almacenar artefactos de workflow](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts)
- [Escribir en el resumen del job](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#adding-a-job-summary)
