# Guía del instructor

Para quien imparte la sesión. Los participantes no necesitan leer esto.

## A quién está dirigido

Gente que usa Git y GitHub para trabajar (clonar, ramas, commits, PRs) y que
**nunca ha escrito un workflow de Actions**. Esa es la premisa del rediseño.
Si tu grupo ya escribe pipelines, este material les va a quedar corto y
conviene saltarse a los extras del ejercicio 07.

Verifícalo antes de la sesión, no lo asumas. Una pregunta en el chat de
inscripción basta: "¿has escrito o modificado un archivo en `.github/workflows/`?"

## Agenda de 2 horas

| Tiempo | Bloque | Formato |
|--------|--------|---------|
| 0:00 - 0:10 | Preparación y verificación | Cada quien en su máquina, tú circulas |
| 0:10 - 0:25 | Ejercicio 01, primer workflow | Guiado, tú compartes pantalla |
| 0:25 - 0:45 | Ejercicio 02, CI de verdad | Guiado los primeros 5 min, luego solos |
| 0:45 - 1:00 | Ejercicio 03, artefactos y resumen | Solos, tú resuelves dudas |
| 1:00 - 1:05 | Descanso | |
| 1:05 - 1:25 | Ejercicio 04, dos jobs y workflow roto | Parte A guiada, parte B individual |
| 1:25 - 1:45 | Ejercicio 05, proteger main | Guiado, es el que más se atora |
| 1:45 - 1:57 | Ejercicio 06, tags y releases | Solos |
| 1:57 - 2:00 | Cierre | |

El bloque que se desborda siempre es el 05, porque depende de la interfaz de
GitHub y de permisos. Si vas retrasado, recorta el 06 y déjalo de tarea. Es el
más autocontenido de todos.

## Antes de la sesión

Lee [`checklist-previo.md`](checklist-previo.md). Resumen: manda el enlace de
preparación con 48 horas de anticipación, corre tú mismo el laboratorio completo
en un repositorio limpio la semana anterior, y confirma que las versiones de las
acciones siguen vigentes.

## Los tres puntos donde se atora la gente

**Ejercicio 02, la rama no dispara el workflow.** El filtro es `lab/**`. Alguien
va a nombrar su rama `mi-prueba` y va a pasar cinco minutos preguntándose por
qué no pasa nada. Dilo en voz alta antes de que empiecen.

**Ejercicio 05, el check requerido no aparece.** Solo aparece en la lista si ya
corrió al menos una vez en ese repositorio. Como todos ya hicieron los
ejercicios 02 a 04, debería estar. Si alguien saltó ejercicios, no va a estar.

**Ejercicio 05, se bloquean a sí mismos.** Si ponen `Required approvals: 1`
estando solos, no pueden aprobar su propio PR y quedan trabados. El documento
lo dice explícitamente, pero la gente marca casillas sin leer. Anúncialo.

## Qué recortar si vas tarde

En este orden:

1. Ejercicio 06 completo. Se manda de tarea, funciona bien solo.
2. Ejercicio 04 parte A (los dos jobs). Conceptualmente es lo menos urgente.
3. Ejercicio 03, el paso 5 (comprobar `if: always()`).

Qué **no** recortar bajo ninguna circunstancia: el ejercicio 01. Es el que
convierte Actions de magia en mecanismo. Si el grupo lo salta, el resto de la
sesión es copiar y pegar YAML sin entender.

## Decisiones de diseño

**El repositorio es público.** No es una preferencia. Los rulesets y la
protección de ramas no están disponibles en repositorios privados con GitHub
Free, y los minutos de Actions son gratis e ilimitados en públicos con runners
estándar. Si tu audiencia está en una organización con Enterprise, puedes usar
privado, pero verifica el plan antes.

**El pipeline empieza con un solo job.** El material anterior arrancaba con
cuatro jobs encadenados, outputs, artefactos y matrix. Para alguien que nunca
vio Actions, eso son cinco conceptos simultáneos y el resultado predecible es
que copien el YAML sin entenderlo.

**El chequeo de formato salió del pipeline principal.** Tener
`dotnet format --verify-no-changes` como primer job significa que el primer run
de un participante probablemente falle por un espacio en blanco antes de haber
entendido qué es un job. Es la peor primera impresión posible de CI.

**El workflow roto tiene 4 errores, todos verificables leyendo.** Ninguno es de
sintaxis, porque un error de sintaxis lo encuentra el editor y no enseña nada.

## Cómo evaluar si funcionó

Al final, pregunta esto al grupo. Si no lo pueden responder, el ejercicio
correspondiente no aterrizó:

1. ¿Por qué un workflow necesita `actions/checkout`?
2. Si el paso A escribe un archivo, ¿lo ve el paso B? ¿Y el job B?
3. ¿Qué pasa si `if-no-files-found` se queda en su valor por default y la ruta
   está mal?
4. ¿Qué hace que un PR no se pueda mergear?

## Material de apoyo

- `soluciones/` tiene el estado final de cada archivo. Ténlo abierto.
- Considera crear una rama `solucion-completa` en el repositorio base con todo
  aplicado, para que quien se atore pueda comparar diffs.
- Si trabajas con una organización, crea los repositorios de los participantes
  antes de la sesión. Ahorra los diez minutos del ejercicio 00.
