# Soluciones

Estado final de cada archivo, por ejercicio. Si te atoras, copia el que
corresponde a `.github/workflows/` y sigue avanzando.

| Archivo | Corresponde a | Qué agrega |
|---------|---------------|------------|
| `02-ci.yml` | Ejercicio 02 | Estado inicial, sin cambios |
| `03-ci.yml` | Ejercicio 03 | Artefactos y step summary |
| `04-ci.yml` | Ejercicio 04 | Dos jobs con `needs` y `outputs` |
| `workflow-roto-corregido.yml` | Ejercicio 04 parte B | Los 4 errores corregidos y comentados |
| `06-release.yml` | Ejercicio 06 | Release automático por tag |
| `07-packages.yml` | Extra A | Publicación a GitHub Packages |
| `08-matrix.yml` | Extra B | Matrix strategy |

Las respuestas escritas están en [`respuestas.md`](respuestas.md).

## Cómo usarlas

```bash
# Ejemplo: quedarte con el estado del ejercicio 03
cp soluciones/03-ci.yml .github/workflows/01-ci.yml
git add .github/workflows/01-ci.yml
git commit -m "ci: estado del ejercicio 03"
git push
```

Los archivos de `soluciones/` no viven en `.github/workflows/`, así que no se
ejecutan solos. Es intencional: si estuvieran ahí, cada push dispararía siete
workflows.
