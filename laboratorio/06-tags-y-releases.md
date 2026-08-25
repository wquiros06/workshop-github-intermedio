# 06. Tags y releases

**Tiempo:** 15 minutos.

## Qué vas a lograr

Marcar un punto del historial con un tag SemVer, y que empujar ese tag dispare
un workflow que publica un release con el paquete adjunto.

## Contexto

Un tag es un nombre para un commit. Nada más. Un release es un objeto de GitHub
construido encima de un tag: agrega notas, archivos adjuntos y una URL estable
de descarga.

Dos tipos de tag:

- **Ligero**: un puntero al commit y ya.
- **Anotado**: un objeto propio en Git con autor, fecha, mensaje y opción de
  firma.

Usa anotados para versiones. Cuando alguien pregunte en seis meses quién cortó
la 1.2.0 y por qué, el tag anotado responde y el ligero no.

## Paso 1: crear el tag

Versionamiento semántico es `MAYOR.MENOR.PARCHE`:

- **MAYOR** sube cuando rompes compatibilidad.
- **MENOR** sube cuando agregas funcionalidad compatible.
- **PARCHE** sube cuando corriges algo sin cambiar la API.

En el ejercicio 02 agregaste `MonthlyPayment`, un método nuevo que no rompe
nada. Eso es un incremento MENOR.

```bash
git checkout main
git pull

git tag -a v1.1.0 -m "Agrega calculo de pago mensual de prestamos"
git push origin v1.1.0
```

Verifica:

```bash
git tag -n
git show v1.1.0
```

Si te equivocas de commit, borra y rehaz **antes de que alguien más lo use**:

```bash
git tag -d v1.1.0
git push origin --delete v1.1.0
```

Mover un tag que ya está publicado rompe cualquier cosa que dependa de él.
Trátalos como inmutables una vez que salen de tu máquina.

## Paso 2: el workflow de release

Copia `soluciones/06-release.yml` a `.github/workflows/06-release.yml`.

Lo importante:

```yaml
on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write
```

`permissions: contents: write` es obligatorio. Sin eso, el paso que crea el
release falla con 403. Es el error que más se repite cuando alguien copia un
workflow de release de un blog, porque el default de permisos del token cambió
en su momento y la mayoría de los ejemplos viejos no lo incluyen.

```yaml
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
```

`checkout` clona solo el último commit por default. Las notas automáticas del
release necesitan el historial para comparar contra el tag anterior.

```yaml
      - name: Crear el release con el paquete adjunto
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh release create "$GITHUB_REF_NAME" \
            ./paquete/*.nupkg \
            --title "$GITHUB_REF_NAME" \
            --generate-notes
```

`gh` viene preinstalado en los runners de GitHub, pero necesita el token en
`GH_TOKEN` para autenticarse. `--generate-notes` arma las notas a partir de los
PRs mergeados desde el tag anterior.

Súbelo por PR, porque `main` está protegida:

```bash
git checkout -b lab/06-release
git add .github/workflows/06-release.yml
git commit -m "ci: workflow de release por tag"
git push -u origin lab/06-release
gh pr create --fill --base main
```

Espera el check, haz merge, y regresa a main:

```bash
git checkout main
git pull
```

## Paso 3: disparar el release

El tag `v1.1.0` ya existe pero se creó antes del workflow, así que no disparó
nada. Crea el siguiente:

```bash
git tag -a v1.1.1 -m "Publicar release desde el pipeline"
git push origin v1.1.1

gh run watch
```

Cuando termine:

```bash
gh release list
gh release view v1.1.1
```

En el navegador, la sección **Releases** de tu repositorio muestra el release
con las notas generadas y el `.nupkg` adjunto.

## Paso 4: releases hechos a mano

No todo tiene que pasar por un workflow:

```bash
git tag -a v1.2.0 -m "Version manual"
git push origin v1.2.0
gh release create v1.2.0 --generate-notes --title "v1.2.0"
```

Esto te va a crear un release duplicado si el workflow del paso 3 también
corre con el patrón `v*`. Es un buen momento para pensar en qué disparadores
tienes activos: dos rutas que crean el mismo objeto es una fuente clásica de
confusión en pipelines de release.

## Cómo sabes que terminaste

- `gh release list` muestra al menos un release.
- El release tiene un archivo `.nupkg` adjunto.
- Las notas se generaron solas a partir de los commits o PRs.

## Cuando algo falla

| Síntoma | Qué pasó |
|---------|----------|
| El workflow no corre al empujar el tag | El patrón `tags: ['v*']` distingue mayúsculas. Un tag `V1.0.0` no coincide. |
| `HTTP 403: Resource not accessible by integration` | Falta `permissions: contents: write`. |
| `gh: To use GitHub CLI in a GitHub Actions workflow, set the GH_TOKEN environment variable` | Falta el bloque `env: GH_TOKEN`. |
| `--generate-notes` no genera nada | Falta `fetch-depth: 0` en el checkout, o es el primer tag y no hay contra qué comparar. |
| `dotnet pack` no encuentra el csproj | La ruta es relativa a la raíz del repositorio. |
| El release sale sin el `.nupkg` | El glob `./paquete/*.nupkg` no encontró archivos. Agrega un `ls -la ./paquete` antes para diagnosticar. |

## Referencia

- [Gestionar releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- [Permisos del GITHUB_TOKEN](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Especificación de SemVer](https://semver.org/lang/es/)
