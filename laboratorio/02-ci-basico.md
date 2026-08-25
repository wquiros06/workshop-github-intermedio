# 02. CI de verdad

**Tiempo:** 20 minutos.

## Qué vas a lograr

Que cada push a una rama compile el proyecto y corra las pruebas
automáticamente, y ver el pipeline fallar cuando rompes una prueba.

## Contexto

El workflow del ejercicio 01 imprimía texto. Este hace el trabajo real, y son
exactamente los mismos cuatro conceptos: `on`, `runs-on`, `steps`, y ahora dos
acciones prefabricadas.

El archivo ya está en `.github/workflows/01-ci.yml`. Ábrelo.

## Paso 1: leer el pipeline

Lo nuevo respecto al ejercicio anterior:

```yaml
on:
  push:
    branches:
      - main
      - 'lab/**'      # cualquier rama que empiece con lab/
  pull_request:
    branches:
      - main          # cuando se abre un PR APUNTANDO a main
  workflow_dispatch:
```

Un punto que confunde a todo el mundo: en `pull_request`, `branches` filtra por
la rama **destino**, no por la rama origen. `branches: [main]` significa "PRs
hacia main", venga de donde venga.

```yaml
      - uses: actions/checkout@v7
```

Sin este paso el runner está vacío. GitHub no clona tu código por default. Es
la causa número uno de "no such file or directory" en un workflow nuevo.

```yaml
      - uses: actions/setup-dotnet@v6
        with:
          dotnet-version: '9.0.x'
```

Instala el SDK. `with:` son los parámetros de la acción, equivalentes a los
argumentos de una función.

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

Si haces tres push seguidos, cancela los dos runs viejos. Ahorra minutos y
evita que revises logs de código que ya no existe.

## Paso 2: dispararlo con un cambio real

```bash
git checkout -b lab/02-ci
```

Abre `src/FinancialUtils/Calculator.cs` y agrega un método al final de la clase,
antes de la última llave:

```csharp
    /// <summary>
    /// Calcula el pago mensual de un préstamo con tasa fija.
    /// </summary>
    public static decimal MonthlyPayment(decimal principal, decimal annualRate, int months)
    {
        if (months <= 0)
            throw new ArgumentOutOfRangeException(nameof(months), "El plazo debe ser positivo.");

        if (annualRate == 0)
            return principal / months;

        var monthlyRate = annualRate / 12m;
        var factor = (decimal)Math.Pow(1 + (double)monthlyRate, months);

        return principal * monthlyRate * factor / (factor - 1);
    }
```

Compila y prueba localmente antes de subir. Este hábito te ahorra runs
fallidos y minutos de CI:

```bash
dotnet build --configuration Release
dotnet test --configuration Release --no-build
```

Sube:

```bash
git add src/FinancialUtils/Calculator.cs
git commit -m "feat: agregar calculo de pago mensual"
git push -u origin lab/02-ci
```

## Paso 3: verlo correr

```bash
gh run watch
```

O en la pestaña Actions del navegador. Debe pasar en verde en aproximadamente
un minuto.

## Paso 4: verlo fallar

Ahora rompe algo de verdad. Abre `tests/FinancialUtils.Tests/CalculatorTests.cs`
y agrega una prueba que va a fallar:

```csharp
    [Fact]
    public void MonthlyPayment_DeberiaFallarAProposito()
    {
        var resultado = Calculator.MonthlyPayment(100_000m, 0.12m, 12);
        Assert.Equal(999m, resultado);
    }
```

```bash
git add tests/
git commit -m "test: prueba que falla a proposito"
git push
```

Observa el run. El paso **Ejecutar pruebas** se pone rojo y el job se detiene
ahí. Los pasos posteriores no corren. Abre el log y busca la línea que dice
`Failed` con el nombre de la prueba y los valores esperado y real.

Esto es lo que hace útil a CI. No es que corra pruebas, es que las corre en una
máquina limpia que no tiene tu caché, tu configuración local ni tus variables
de entorno.

Ahora arréglalo borrando la prueba:

```bash
git revert --no-edit HEAD
git push
```

## Paso 5: abrir el PR

```bash
gh pr create --fill --base main
```

En la página del PR aparece la sección de checks abajo. El mismo workflow corre
otra vez, ahora por el evento `pull_request`. **No lo hagas merge todavía.** Lo
vas a necesitar en el ejercicio 05.

## Cómo sabes que terminaste

- Tienes un run verde y un run rojo en la rama `lab/02-ci`.
- Tienes un PR abierto hacia `main` con el check de CI en verde.
- Puedes explicar por qué el pipeline necesita `actions/checkout`.

## Cuando algo falla

| Síntoma | Qué pasó |
|---------|----------|
| El workflow no se dispara con el push | Tu rama no coincide con los patrones. Debe llamarse `lab/algo`. Revisa con `git branch --show-current`. |
| `MSBUILD : error MSB1003` | El runner no tiene tu código. Falta `actions/checkout`, o el paso está después del que lo necesita. |
| `The SDK 'Microsoft.NET.Sdk' specified could not be found` | Falta `setup-dotnet`, o la versión no coincide con el `TargetFramework` del csproj. |
| El run corre dos veces por push | Normal si tienes push y pull_request activos en una rama con PR abierto. Es esperado, no un bug. |
| `dotnet test --no-build` dice que no encuentra el assembly | Compilaste en Debug y estás probando en Release, o al revés. Las dos banderas `--configuration` deben coincidir. |

## Antes de continuar

Los logs del run se borran a los 90 días y no puedes buscarlos ni compartirlos
fácilmente. Si el pipeline genera un reporte de cobertura, un binario o un
paquete, necesitas sacarlo del runner antes de que la máquina se destruya. Eso
es el ejercicio 03.
