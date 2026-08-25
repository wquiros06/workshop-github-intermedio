# 07. Extras

Estos ejercicios no caben en dos horas. Están aquí para después de la sesión, o
para el grupo que va adelantado.

Cada uno tiene su solución en `soluciones/`.

---

## A. Publicar a GitHub Packages

**Solución:** `soluciones/07-packages.yml`

Publicar el `.nupkg` en el registro NuGet de GitHub, para que otros proyectos de
tu organización lo consuman.

Los dos puntos donde falla:

1. Falta `permissions: packages: write`.
2. La URL del registro apunta al owner equivocado. Debe ser el dueño del
   repositorio, `https://nuget.pkg.github.com/OWNER/index.json`. Si el repo está
   en una organización, `OWNER` es la organización, no tu usuario.

Para consumirlo desde otro proyecto necesitas un `nuget.config` con la fuente y
credenciales. En una máquina de desarrollo eso significa un PAT con scope
`read:packages`. Es el punto donde la mayoría de los equipos decide que un feed
de Azure Artifacts les resuelve mejor la vida, y es una decisión legítima.

Cuándo usar GitHub Packages: paquetes internos, consumidos por gente que ya
tiene acceso al repositorio, con el ciclo de vida atado al mismo repo.

Cuándo no: paquetes públicos, que van a nuget.org. Y feeds corporativos con
políticas de retención o upstream que GitHub Packages no cubre.

**Referencia:**
[Trabajar con el registro de NuGet](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-nuget-registry)

---

## B. Matrix strategy

**Solución:** `soluciones/08-matrix.yml`

Correr el mismo job contra varias combinaciones de sistema operativo y versión
de runtime.

```yaml
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        dotnet: ['9.0.x']
```

Antes de copiar esto a un proyecto real, haz la cuenta. Cada combinación es un
runner completo. En repositorios privados, Windows consume el doble de minutos
que Linux y macOS diez veces más
([documentación de facturación](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)).
Una matriz de 3 sistemas por 3 versiones no cuesta 9 veces un job, cuesta
bastante más.

`fail-fast: false` es casi siempre lo que quieres al diagnosticar. Con el
default en `true`, la primera combinación que falla cancela las demás y te
quedas sin saber si el problema es de una plataforma o de todas.

---

## C. Caché de dependencias

`setup-dotnet` soporta caché de NuGet:

```yaml
      - uses: actions/setup-dotnet@v6
        with:
          dotnet-version: '9.0.x'
          cache: true
          cache-dependency-path: '**/packages.lock.json'
```

Advertencia honesta: en este proyecto no va a hacer diferencia medible. Son dos
proyectos con cuatro paquetes. El caché empieza a pagar cuando el restore toma
más de treinta segundos.

Además, el caché tiene su propio costo: cuota de almacenamiento, y una clase de
bug bastante desagradable cuando un caché corrupto hace fallar builds que
deberían pasar. No lo agregues por default, agrégalo cuando midas que el
restore es tu cuello de botella.

---

## D. Reusable workflows

Un workflow con `on: workflow_call` puede ser invocado por otros workflows,
igual que una acción.

```yaml
# .github/workflows/reusable-build.yml
on:
  workflow_call:
    inputs:
      dotnet-version:
        required: true
        type: string
```

```yaml
# quien lo consume
jobs:
  ci:
    uses: ./.github/workflows/reusable-build.yml
    with:
      dotnet-version: '9.0.x'
```

Restricciones que importan:

- Un archivo con `workflow_call` no puede tener otros disparadores.
- Se anidan hasta 4 niveles.
- Para consumirlo desde otro repositorio, ese repositorio debe ser público o
  estar en la misma organización con acceso configurado.

Cuándo vale la pena: cuando tienes el mismo pipeline repetido en más de tres
repositorios. Antes de eso, la abstracción cuesta más de lo que ahorra.

Diferencia con una composite action: el reusable workflow define jobs completos
y controla `runs-on`; una composite action define pasos que se insertan dentro
de un job existente.

---

## E. Commits firmados

Verificar que el autor de un commit es quien dice ser. Con SSH es lo más simple:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

Luego registra la misma llave en GitHub como **Signing Key** en Settings > SSH
and GPG keys. Es una entrada separada de la llave de autenticación, aunque sea
el mismo archivo.

Para exigirlo, agrega **Require signed commits** a tu ruleset.

Advertencia práctica: si lo activas en un repositorio con gente que no tiene
llaves configuradas, bloqueas a todo el equipo. Actívalo en modo `Evaluate`
primero, revisa quién falla, y recién entonces pásalo a `Active`.

---

## F. Seguridad del pipeline

Tres cosas que separan un pipeline de demo de uno de producción:

**Permisos explícitos.** Declara `permissions:` en cada workflow con lo mínimo.
El default se configura a nivel de repositorio y organización, así que no
asumas cuál es.

**Fijar acciones de terceros por SHA.** `uses: alguien/accion@v1` apunta a un
tag mutable. Quien controla ese repositorio puede mover el tag y ejecutar código
distinto en tu pipeline. Para acciones fuera de `actions/` y de tu organización,
fija el commit completo:

```yaml
      - uses: tercero/accion@a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0  # v1.2.3
```

**Cuidado con `pull_request_target`.** Ese disparador corre con permisos de
escritura y acceso a secrets sobre código de un PR que puede venir de un fork.
Es el vector de ataque más común contra pipelines públicos. Si no sabes por qué
lo necesitas, no lo uses.

**Referencia:**
[Endurecimiento de seguridad para GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use)
