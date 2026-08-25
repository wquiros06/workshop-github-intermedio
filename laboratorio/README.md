# Laboratorio

Los ejercicios están numerados y son secuenciales. Cada uno deja el repositorio
en un estado que el siguiente da por hecho, así que no los saltes.

| # | Ejercicio | Tiempo | Qué construyes |
|---|-----------|--------|----------------|
| 00 | [Preparación](00-preparacion.md) | 10 min | Tu copia del repo, funcionando |
| 01 | [Tu primer workflow](01-primer-workflow.md) | 15 min | Un workflow manual que imprime texto |
| 02 | [CI de verdad](02-ci-basico.md) | 20 min | Compilar y probar en cada push |
| 03 | [Artefactos y resumen](03-artefactos-y-resumen.md) | 15 min | Reportes descargables y un resumen legible |
| 04 | [Dos jobs y diagnóstico](04-dos-jobs-y-diagnostico.md) | 20 min | `needs`, y encontrar 4 errores en un YAML roto |
| 05 | [Proteger main](05-proteger-main.md) | 20 min | Ruleset, CODEOWNERS y un PR bloqueado por CI |
| 06 | [Tags y releases](06-tags-y-releases.md) | 15 min | Un tag SemVer y un release publicado |
| 07 | [Extras](07-extras.md) | Opcional | Packages, matrix, caché |

## Cómo leer cada ejercicio

Todos tienen la misma estructura:

- **Qué vas a lograr**: el resultado concreto, en una frase.
- **Contexto**: por qué esto importa fuera del salón.
- **Pasos**: comandos y archivos literales. Copiar y pegar funciona.
- **Cómo sabes que terminaste**: la verificación. Si no la pasas, no avances.
- **Cuando algo falla**: los errores que la gente comete en este ejercicio.

## Si te quedas atrás

En `soluciones/` está el estado final de cada archivo. Copia el que corresponde,
sigue avanzando y regresa después. Quedarte trabado veinte minutos en una
indentación de YAML no te enseña nada que valga esos veinte minutos.
