# Contribuir

Este repositorio es material de workshop. Las contribuciones más útiles son las
correcciones que encontraste impartiéndolo o tomándolo.

## Qué reportar

- Un paso del laboratorio que no funciona como está escrito
- Una versión de acción o de SDK que quedó desactualizada
- Un error que tus participantes cometieron y que no está en la tabla de
  "Cuando algo falla" del ejercicio correspondiente

Ese último tipo de reporte es el más valioso. Cada error real que se documenta
son minutos que la siguiente persona no pierde.

## Cómo

1. Crea una rama con el prefijo `lab/` o `fix/`
2. Haz tus cambios
3. Verifica que el proyecto sigue compilando: `bash scripts/verificar-entorno.sh`
4. Abre un pull request describiendo el problema que resuelve

## Estilo

- Español neutro, sin regionalismos
- Segunda persona ("vas a", "verifica"), consistente con el resto del material
- Los comandos deben poder copiarse y pegarse tal cual
- Cada afirmación sobre el comportamiento de la plataforma va con enlace a la
  documentación oficial
- Nada de "es muy fácil" ni "simplemente". Si fuera fácil no harías el workshop

## Cambios en los workflows

Si modificas un YAML de `.github/workflows/`, actualiza también el archivo
correspondiente en `soluciones/`. Se desincronizan con facilidad y un
participante que copia una solución desactualizada pierde más tiempo que si no
existiera.
