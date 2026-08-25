# 05. Proteger main

**Tiempo:** 20 minutos.

## Qué vas a lograr

Que nadie pueda empujar directo a `main`, que todo entre por pull request, y
que el PR quede bloqueado si el pipeline falla.

## Contexto

CI que no bloquea nada es un semáforo apagado. Si el equipo puede hacer merge
con los checks en rojo, el pipeline es decorativo.

Hay dos mecanismos en GitHub para esto:

**Branch protection rules** es el mecanismo clásico. Una regla por patrón de
rama, configurada en Settings > Branches.

**Rulesets** es el mecanismo actual. Hace lo mismo y agrega tres cosas que
importan en organizaciones: se pueden aplicar a varios repos desde la
organización, tienen modo de evaluación para probar sin bloquear, y permiten
listas de bypass explícitas.

Para un repositorio nuevo, usa rulesets. Los branch protection rules siguen
funcionando y conviven, pero no hay razón para empezar ahí.

Requisito de plan: rulesets y branch protection están disponibles en
repositorios públicos con GitHub Free, y en públicos y privados con Pro, Team o
Enterprise
([documentación](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository)).
Por eso el ejercicio 00 te pidió crear el repo público.

## Paso 1: crear el ruleset

1. En tu repositorio: **Settings > Rules > Rulesets > New ruleset > New branch
   ruleset**.
2. **Ruleset Name**: `proteger-main`
3. **Enforcement status**: `Active`
4. En **Target branches**, clic en **Add target > Include default branch**.
5. Marca estas reglas:
   - **Restrict deletions**
   - **Block force pushes**
   - **Require a pull request before merging**
     - Required approvals: `0` (si estás solo, ponerlo en 1 te bloquea tu
       propio PR y no puedes terminar el ejercicio)
     - Marca **Require review from Code Owners**
   - **Require status checks to pass**
     - Busca y agrega el check llamado `Test`
     - Marca **Require branches to be up to date before merging**
6. **Create**.

Sobre el nombre del check: es el `name:` del job, no el del workflow. Si tu job
se llama `Test`, el check se llama `Test`. Si dos workflows tienen jobs con el
mismo nombre, el check queda ambiguo y puede bloquear merges de forma
impredecible. Nombra tus jobs de forma única entre workflows.

Si el check no aparece en la lista de búsqueda es porque nunca ha corrido en
este repositorio. Corre el workflow una vez y vuelve.

## Paso 2: comprobar que bloquea

```bash
git checkout main
git pull
echo "prueba" >> README.md
git add README.md
git commit -m "test: push directo a main"
git push
```

Debe fallar con un mensaje de protected branch. Limpia:

```bash
git reset --hard origin/main
```

Si el push pasó, revisa dos cosas: que el ruleset esté en `Active` y no en
`Evaluate`, y que tu cuenta no esté en la lista de bypass. Ser dueño del
repositorio no te exenta a menos que lo configures así.

## Paso 3: CODEOWNERS

`.github/CODEOWNERS` define quién debe revisar qué. Cuando un PR toca archivos
que coinciden con un patrón, GitHub pide review automáticamente al owner.

Ábrelo y reemplaza `@TU_USUARIO` por tu usuario real:

```bash
sed -i 's/@TU_USUARIO/@tu-usuario-de-github/g' .github/CODEOWNERS
```

En macOS usa `sed -i ''` en lugar de `sed -i`.

Reglas del archivo que casi siempre se malinterpretan:

- **Gana la última regla que coincide**, no la más específica. Si tienes `*` al
  inicio y `/src/` después, un cambio en `src/` va al owner de `/src/`. Si
  inviertes el orden, el `*` se come todo.
- Los owners **deben tener acceso de escritura** al repositorio. Un usuario sin
  acceso se ignora en silencio, sin advertencia.
- Un `@equipo` requiere que el equipo tenga acceso al repositorio, no basta con
  que exista en la organización.
- CODEOWNERS por sí solo no bloquea nada. Solo pide review. Para que bloquee
  necesitas **Require review from Code Owners** activado en el ruleset, que ya
  marcaste en el paso 1.

Sube el cambio en una rama, porque `main` ya está protegida:

```bash
git checkout -b lab/05-codeowners
git add .github/CODEOWNERS
git commit -m "chore: definir code owners"
git push -u origin lab/05-codeowners
gh pr create --fill --base main
```

## Paso 4: ver el bloqueo en acción

Toma el PR que dejaste abierto en el ejercicio 02. Rompe una prueba en esa rama
y súbela:

```bash
git checkout lab/02-ci
```

Cambia cualquier valor esperado en `tests/FinancialUtils.Tests/CalculatorTests.cs`
para que falle.

```bash
git add tests/
git commit -m "test: romper una prueba"
git push
```

Abre el PR en el navegador. El check `Test` sale en rojo y el botón de merge
está deshabilitado con el mensaje de que los checks requeridos no pasaron.

Arregla la prueba, haz push, y observa cómo el botón se habilita solo.

## Paso 5: estrategias de merge

En **Settings > General > Pull Requests** están las tres opciones. No hay una
correcta, hay consecuencias:

| Opción | Qué deja en main | Cuándo tiene sentido |
|--------|------------------|----------------------|
| Merge commit | Todos los commits de la rama más un commit de merge | Cuando el historial detallado de la rama importa, por ejemplo en auditorías |
| Squash | Un solo commit por PR | Equipos que hacen commits de trabajo en progreso. Historial limpio y `git bisect` útil |
| Rebase | Los commits de la rama, sin commit de merge | Historial lineal. Reescribe SHAs, lo que complica el rastreo si alguien ya tenía la rama |

Para la mayoría de los equipos de producto, squash es el default razonable. La
condición es que el título del PR sea descriptivo, porque se convierte en el
mensaje del commit.

Deja activada solo la opción que tu equipo va a usar. Tener las tres activas
garantiza que el historial sea inconsistente.

## Cómo sabes que terminaste

- Un push directo a `main` te da error.
- Tienes un PR donde el botón de merge está bloqueado por el check en rojo.
- El mismo PR se desbloquea al arreglar la prueba.
- CODEOWNERS tiene tu usuario real y el PR muestra la solicitud de review.

## Cuando algo falla

| Síntoma | Qué pasó |
|---------|----------|
| No veo la opción Rulesets | Repositorio privado con plan Free. Cámbialo a público en Settings > General > Danger Zone. |
| El check requerido no aparece en la búsqueda | Nunca ha corrido. Dispara el workflow una vez, luego regresa al ruleset. |
| El PR se queda esperando el check para siempre | El nombre del check en el ruleset no coincide con el `name:` del job. Cópialo exacto. |
| Puedo hacer merge con checks rojos | Tu cuenta está en la lista de bypass del ruleset, o el ruleset está en `Evaluate`. |
| CODEOWNERS no pide review | El usuario no tiene acceso de escritura, o el archivo tiene un typo. GitHub marca los errores de sintaxis en la vista del archivo. |
| Bloqueé mi propio PR y estoy solo | Baja `Required approvals` a 0. Con una sola persona no puedes aprobar tu propio PR. |
