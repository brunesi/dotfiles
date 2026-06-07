# Análise estática C com Cppcheck + MISRA C no Windows/PowerShell

Este documento registra um fluxo prático para instalar, configurar e executar análise estática em C usando **Cppcheck** e o addon **MISRA C** no Windows, via **PowerShell**.

O exemplo concreto usado aqui é o projeto DNP3:

```text
C:\GVs\Perseus\firmware\dnp\perseus-comm-module-firmware-lactec
```

mas a estrutura foi pensada para ser reutilizada em outros projetos.

---

## 1. Objetivo do fluxo

O objetivo é ter uma análise estática em duas camadas:

1. **Cppcheck normal**
   - Verifica problemas gerais de C/C++.
   - Exemplo: variável não usada, possíveis bugs, estilo, problemas de configuração.

2. **MISRA C via addon do Cppcheck**
   - Usa o `misra.py`.
   - Trabalha sobre um arquivo intermediário `.dump` gerado pelo Cppcheck.
   - Produz violações do tipo `misra-c2012-x.y`.

O fluxo adotado é em duas etapas porque ficou mais robusto e mais fácil de diagnosticar:

```text
cppcheck --dump arquivo.c
python misra.py --rule-texts=... arquivo.c.dump
```

Em vez de depender apenas de:

```text
cppcheck --addon=misra.json arquivo.c
```

---

## 2. Instalação do Cppcheck no Windows

Instale o Cppcheck para Windows.

Durante a instalação, é importante habilitar também os:

```text
Python addons
```

Sem essa opção, o `misra.py` pode não ser instalado.

Depois da instalação, o executável ficou em:

```text
C:\Program Files\Cppcheck\cppcheck.exe
```

Os addons Python ficaram em:

```text
C:\Program Files\Cppcheck\addons
```

Arquivos importantes nessa pasta:

```text
C:\Program Files\Cppcheck\addons\misra.py
C:\Program Files\Cppcheck\addons\cppcheckdata.py
C:\Program Files\Cppcheck\addons\misra_9.py
```

---

## 3. Testando o Cppcheck no PowerShell

Se o Cppcheck não estiver no `PATH`, o comando abaixo não funcionará:

```powershell
cppcheck --version
```

Nesse caso, use uma variável no PowerShell:

```powershell
$cppcheck = "C:\Program Files\Cppcheck\cppcheck.exe"
```

E execute com o operador `&`:

```powershell
& $cppcheck --version
```

Quando o caminho do executável tem espaços e está entre aspas, o PowerShell precisa do `&` para executar o conteúdo como comando.

Também é possível testar diretamente:

```powershell
& "C:\Program Files\Cppcheck\cppcheck.exe" --version
```

---

## 4. Testando o Python e o addon MISRA

O addon MISRA é um script Python. Portanto, o Python precisa estar disponível no PowerShell.

Teste:

```powershell
python --version
```

ou:

```powershell
py --version
```

Depois teste o addon:

```powershell
python "C:\Program Files\Cppcheck\addons\misra.py" --help
```

Se o comando acima responder, o `misra.py` está acessível.

---

## 5. Estrutura recomendada das pastas

A recomendação é separar:

1. **Pasta do projeto analisado**
2. **Pasta da infraestrutura de análise**

### 5.1. Pasta do projeto analisado

É a pasta onde está o código-fonte real.

No exemplo DNP3:

```text
C:\GVs\Perseus\firmware\dnp\perseus-comm-module-firmware-lactec
```

No script, essa pasta será chamada de:

```powershell
$projectDir
```

### 5.2. Pasta raiz das análises Cppcheck/MISRA

Foi criada uma raiz geral para análises:

```text
C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck
```

Dentro dela, recomenda-se criar uma pasta por alvo de análise.

Exemplo:

```text
C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\mvp
C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3
```

### 5.3. Estrutura por projeto analisado

Para o MVP simples:

```text
...\cppcheck\mvp
├── file1.c
├── misra-rule-texts.txt
├── misra.json
├── dumps
├── results
└── run-cppcheck-misra.ps1
```

Para o projeto DNP3:

```text
...\cppcheck\DNP3
├── misra-rule-texts.txt
├── misra.json
├── dumps
├── results
└── run-cppcheck-misra.ps1
```

A pasta `dumps` recebe os arquivos `.dump`.

A pasta `results` recebe os relatórios.

Isso evita sujar a árvore Git do projeto analisado com arquivos temporários.

---

## 6. Arquivo `misra-rule-texts.txt`

O Cppcheck não distribui os textos das regras MISRA, pois eles pertencem ao material oficial da MISRA.

Para que o addon mostre mensagens úteis, foi criado um arquivo:

```text
misra-rule-texts.txt
```

No exemplo DNP3, ele fica em:

```text
C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3\misra-rule-texts.txt
```

Formato usado:

```text
Appendix A Summary of guidelines

Rule 21.6 Required

The Standard Library input/output functions shall not be used.
```

Exemplo de outra regra:

```text
Rule 7.1 Required

Octal constants shall not be used.
```

---

## 7. Arquivo `misra.json`

Embora o fluxo principal adotado chame o `misra.py` diretamente, ainda é útil manter um `misra.json` para testes com `--addon`.

Exemplo para o DNP3:

```json
{
  "script": "C:/Program Files/Cppcheck/addons/misra.py",
  "args": [
    "--rule-texts=C:/L/projetos/Perseus 2439/stm32/Static analysis/tools/cppcheck/DNP3/misra-rule-texts.txt"
  ]
}
```

Observação: no JSON, usar `/` nos caminhos do Windows simplifica bastante, pois evita ter que escapar `\`.

---

## 8. Script PowerShell generalizado

Este script analisa uma lista de arquivos `.c`.

Ele faz três etapas para cada arquivo:

1. Cppcheck normal.
2. Geração do `.dump`.
3. Análise MISRA sobre o `.dump`.

Salve como:

```text
run-cppcheck-misra.ps1
```

Exemplo para o projeto DNP3:

```text
C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3\run-cppcheck-misra.ps1
```

### Script

```powershell
# ============================================================
# Cppcheck + MISRA analysis script
# Generic PowerShell version
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Tools
# ------------------------------------------------------------

$cppcheck = "C:\Program Files\Cppcheck\cppcheck.exe"
$misraPy  = "C:\Program Files\Cppcheck\addons\misra.py"

# ------------------------------------------------------------
# Analysis/project paths
#
# $analysisDir:
#   Folder containing this analysis setup:
#   - misra-rule-texts.txt
#   - dumps\
#   - results\
#   - this script
#
# $projectDir:
#   Root folder of the actual C project being analyzed.
# ------------------------------------------------------------

$analysisDir = "C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3"
$projectDir  = "C:\GVs\Perseus\firmware\dnp\perseus-comm-module-firmware-lactec"

$dumpsDir   = Join-Path $analysisDir "dumps"
$resultsDir = Join-Path $analysisDir "results"

$ruleTexts = Join-Path $analysisDir "misra-rule-texts.txt"

# ------------------------------------------------------------
# Files to analyze
#
# Paths are relative to $projectDir.
# Do not start with ".\".
# ------------------------------------------------------------

$targetFiles = @(
    "App\dnp.c"
)

# ------------------------------------------------------------
# Common Cppcheck arguments
#
# These are project-specific.
# For a new project, update include paths and defines here.
# ------------------------------------------------------------

$commonCppcheckArgs = @(
    "--std=c17",
    "--suppress=missingIncludeSystem",

    "-I$projectDir\App",
    "-I$projectDir\App\security",
    "-I$projectDir\App\json",

    "-I$projectDir\Middlewares\triangle",
    "-I$projectDir\Middlewares\triangle\tmwscl\tmwtarg",

    "-I$projectDir\Middlewares\ST\threadx\common\inc",
    "-I$projectDir\Middlewares\ST\netxduo\common\inc",

    "-I$projectDir\AZURE_RTOS\App",

    "-I$projectDir\Middlewares\ST\STM32_Cellular\Interface\Com\Inc",
    "-I$projectDir\Middlewares\ST\STM32_Cellular\Core\Cellular_Service\Inc",

    "-I$projectDir\Drivers\STM32U5xx_HAL_Driver\Inc",
    "-I$projectDir\Drivers\CMSIS\Device\ST\STM32U5xx\Include",
    "-I$projectDir\Drivers\CMSIS\Include"
)

# ------------------------------------------------------------
# Basic checks
# ------------------------------------------------------------

if (-not (Test-Path $cppcheck)) {
    throw "Cppcheck executable not found: $cppcheck"
}

if (-not (Test-Path $misraPy)) {
    throw "MISRA addon not found: $misraPy"
}

if (-not (Test-Path $ruleTexts)) {
    throw "MISRA rule texts file not found: $ruleTexts"
}

if (-not (Test-Path $projectDir)) {
    throw "Project directory not found: $projectDir"
}

New-Item -ItemType Directory -Force $dumpsDir | Out-Null
New-Item -ItemType Directory -Force $resultsDir | Out-Null

# ------------------------------------------------------------
# Run analysis
# ------------------------------------------------------------

foreach ($relativeFile in $targetFiles) {

    $sourceFile = Join-Path $projectDir $relativeFile

    if (-not (Test-Path $sourceFile)) {
        Write-Warning "Source file not found, skipping: $sourceFile"
        continue
    }

    $safeName = $relativeFile `
        -replace "[:\\\/]", "_" `
        -replace "\s+", "_"

    $dumpFile = Join-Path $dumpsDir "$safeName.dump"

    $cppcheckNormalReport = Join-Path $resultsDir "$safeName.cppcheck.txt"
    $cppcheckDumpReport   = Join-Path $resultsDir "$safeName.dump-generation.txt"
    $misraReport          = Join-Path $resultsDir "$safeName.misra.txt"
    $checkersReport       = Join-Path $resultsDir "$safeName.checkers-report.txt"

    Write-Host ""
    Write-Host "============================================================"
    Write-Host "Analyzing: $relativeFile"
    Write-Host "Source:    $sourceFile"
    Write-Host "Dump:      $dumpFile"
    Write-Host "============================================================"

    Remove-Item $dumpFile -ErrorAction SilentlyContinue

    # --------------------------------------------------------
    # 1) Normal Cppcheck analysis
    # --------------------------------------------------------

    & $cppcheck `
        --enable=all `
        @commonCppcheckArgs `
        --template=gcc `
        --checkers-report="$checkersReport" `
        "$sourceFile" `
        *> "$cppcheckNormalReport"

    # --------------------------------------------------------
    # 2) Generate Cppcheck dump
    #
    # Important:
    # cppcheck --dump generates the .dump next to the source file.
    # We move it to $dumpsDir to keep the analyzed project clean.
    # --------------------------------------------------------

    & $cppcheck `
        @commonCppcheckArgs `
        --dump `
        "$sourceFile" `
        *> "$cppcheckDumpReport"

    $generatedDump = "$sourceFile.dump"

    if (-not (Test-Path $generatedDump)) {
        throw "Expected dump was not generated: $generatedDump"
    }

    Move-Item -Force $generatedDump $dumpFile

    # --------------------------------------------------------
    # 3) MISRA analysis over dump
    # --------------------------------------------------------

    python "$misraPy" `
        --rule-texts="$ruleTexts" `
        "$dumpFile" `
        *> "$misraReport"

    Write-Host "Cppcheck report: $cppcheckNormalReport"
    Write-Host "MISRA report:    $misraReport"
}

Write-Host ""
Write-Host "Analysis finished."
Write-Host "Results: $resultsDir"
Write-Host "Dumps:   $dumpsDir"
```

---

## 9. Como executar o script

Abra o PowerShell.

Entre na pasta da análise:

```powershell
cd "C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3"
```

Se necessário, libere execução de script apenas na sessão atual:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Execute:

```powershell
.\run-cppcheck-misra.ps1
```

---

## 10. Arquivos de saída

Para o alvo:

```text
App\dnp.c
```

o script gera nomes seguros trocando `\` por `_`.

Exemplos:

```text
results\App_dnp.c.cppcheck.txt
results\App_dnp.c.dump-generation.txt
results\App_dnp.c.misra.txt
results\App_dnp.c.checkers-report.txt

dumps\App_dnp.c.dump
```

### 10.1. Relatório Cppcheck normal

```text
results\App_dnp.c.cppcheck.txt
```

Contém achados gerais do Cppcheck.

Exemplo:

```text
Variable 'x' is assigned a value that is never used. [unreadVariable]
```

### 10.2. Relatório de geração do dump

```text
results\App_dnp.c.dump-generation.txt
```

Ajuda a diagnosticar problemas na geração do `.dump`.

### 10.3. Relatório MISRA

```text
results\App_dnp.c.misra.txt
```

Contém violações MISRA.

Exemplo:

```text
[file1.c:7] (style) Octal constants shall not be used. (Required) [misra-c2012-7.1]
[file1.c:9] (style) The Standard Library input/output functions shall not be used. (Required) [misra-c2012-21.6]
```

### 10.4. Relatório dos checkers ativos

```text
results\App_dnp.c.checkers-report.txt
```

Mostra quais verificadores do Cppcheck estavam ativos ou não.

---

## 11. Como adaptar para outro projeto

Para usar em outro projeto, normalmente é necessário alterar:

### 11.1. A pasta da análise

```powershell
$analysisDir = "C:\...\cppcheck\NovoProjeto"
```

Essa pasta deve conter:

```text
misra-rule-texts.txt
dumps\
results\
run-cppcheck-misra.ps1
```

Opcionalmente:

```text
misra.json
```

### 11.2. A pasta do projeto

```powershell
$projectDir = "C:\caminho\para\o\projeto"
```

### 11.3. A lista de arquivos

```powershell
$targetFiles = @(
    "Src\main.c",
    "Src\module1.c",
    "Src\module2.c"
)
```

Os caminhos devem ser relativos ao `$projectDir`.

Preferir:

```powershell
"App\dnp.c"
```

em vez de:

```powershell
".\App\dnp.c"
```

### 11.4. Includes e defines

Atualizar:

```powershell
$commonCppcheckArgs = @(
    "--std=c17",
    "--suppress=missingIncludeSystem",

    "-I$projectDir\Inc",
    "-I$projectDir\Drivers\...",
    "-DMACRO_IMPORTANTE=1"
)
```

Para projetos embarcados, essa é geralmente a parte mais importante.

---

## 12. Como descobrir includes faltantes

Se o Cppcheck apontar:

```text
Include file: "nx_api.h" not found. [missingInclude]
```

localize o header com:

```powershell
$projectDir = "C:\caminho\para\o\projeto"

Get-ChildItem "$projectDir" -Recurse -Filter nx_api.h | Select-Object FullName
```

Para vários headers:

```powershell
$headers = @(
    "tmwdb.h",
    "tx_api.h",
    "nx_api.h",
    "stm32u5xx_hal.h"
)

foreach ($h in $headers) {
    Write-Host ""
    Write-Host "=== $h ==="
    Get-ChildItem "$projectDir" -Recurse -Filter $h -File -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName
}
```

Atenção: o `-I` deve apontar para a pasta correta conforme o formato do `#include`.

Exemplo:

```c
#include "tmwscl/utils/tmwdb.h"
```

Se o arquivo real estiver em:

```text
...\Middlewares\triangle\tmwscl\utils\tmwdb.h
```

então o include path correto é:

```powershell
-I"$projectDir\Middlewares\triangle"
```

pois essa é a pasta que contém `tmwscl`.

---

## 13. Exemplo de includes usados no DNP3

Para o projeto analisado aqui, os principais includes encontrados foram:

```powershell
"-I$projectDir\App"
"-I$projectDir\App\security"
"-I$projectDir\App\json"

"-I$projectDir\Middlewares\triangle"
"-I$projectDir\Middlewares\triangle\tmwscl\tmwtarg"

"-I$projectDir\Middlewares\ST\threadx\common\inc"
"-I$projectDir\Middlewares\ST\netxduo\common\inc"

"-I$projectDir\AZURE_RTOS\App"

"-I$projectDir\Middlewares\ST\STM32_Cellular\Interface\Com\Inc"
"-I$projectDir\Middlewares\ST\STM32_Cellular\Core\Cellular_Service\Inc"

"-I$projectDir\Drivers\STM32U5xx_HAL_Driver\Inc"
"-I$projectDir\Drivers\CMSIS\Device\ST\STM32U5xx\Include"
"-I$projectDir\Drivers\CMSIS\Include"
```

Esses includes resolveram a primeira camada de problemas de:

```text
tmwscl/...
tx_api.h
nx_api.h
app_azure_rtos.h
stm32u5xx_hal.h
json/context.h
json/utils.h
```

---

## 14. Diagnóstico de erro comum: `noValidConfiguration`

Erro típico:

```text
This file is not analyzed. No working configuration could be extracted. [noValidConfiguration]
```

Isso normalmente significa que o Cppcheck não conseguiu preprocessar o arquivo.

Causas comuns:

1. includes faltantes;
2. macros importantes não definidas;
3. `#if` que depende de valor não conhecido;
4. configuração de target incompleta.

Exemplo encontrado:

```text
failed to evaluate #if condition, division/modulo by zero
#if ((1000 % TX_TIMER_TICKS_PER_SECOND) != 0)
```

Nesse caso, o ideal foi primeiro corrigir os includes, pois `TX_TIMER_TICKS_PER_SECOND` deveria vir de headers do ThreadX.

Se mesmo após corrigir os includes o problema persistir, pode-se localizar a macro:

```powershell
Get-ChildItem "$projectDir" -Recurse -Include *.h,*.c |
    Select-String "TX_TIMER_TICKS_PER_SECOND" |
    Select-Object Path, LineNumber, Line
```

E, se necessário para análise estática, adicionar um define explícito:

```powershell
-DTX_TIMER_TICKS_PER_SECOND=1000
```

---

## 15. Resultado obtido no DNP3

Depois de corrigir os includes principais, o MISRA passou a processar o arquivo real do DNP3.

Foi gerado um relatório MISRA com resumo semelhante a:

```text
MISRA rules violations found:
    Required: 544
    Advisory: 84
    Undefined: 129
    Mandatory: 158
```

Isso indica que o pipeline está funcionando.

Esse número bruto não deve ser interpretado diretamente como “tudo precisa ser corrigido agora”. Em projetos embarcados reais, especialmente com STM, ThreadX, NetX, HAL e bibliotecas de terceiros, é normal a primeira análise trazer ruído e violações vindas de:

- código próprio;
- headers próprios;
- middleware;
- drivers;
- bibliotecas de vendor;
- macros de configuração;
- padrões aceitos por desvio formal.

---

## 16. Triagem inicial recomendada

O próximo passo após gerar o relatório não é corrigir tudo.

O ideal é separar:

1. violações no `.c` analisado;
2. violações em headers próprios;
3. violações em middleware;
4. violações em drivers/vendor;
5. violações que são ruído de configuração.

### 16.1. Contar violações por arquivo

```powershell
$misraReport = "C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3\results\App_dnp.c.misra.txt"

Select-String -Path $misraReport -Pattern "^\[(.+?):\d+\]" |
    ForEach-Object {
        if ($_.Matches[0].Groups[1].Value) {
            $_.Matches[0].Groups[1].Value
        }
    } |
    Group-Object |
    Sort-Object Count -Descending |
    Select-Object Count, Name
```

### 16.2. Contar violações por arquivo e regra

```powershell
$misraReport = "C:\L\projetos\Perseus 2439\stm32\Static analysis\tools\cppcheck\DNP3\results\App_dnp.c.misra.txt"

Select-String -Path $misraReport -Pattern "^\[(.+?):(\d+)\].*\[(misra-c2012-[^\]]+)\]" |
    ForEach-Object {
        [PSCustomObject]@{
            File = $_.Matches[0].Groups[1].Value
            Line = $_.Matches[0].Groups[2].Value
            Rule = $_.Matches[0].Groups[3].Value
        }
    } |
    Group-Object File, Rule |
    Sort-Object Count -Descending |
    Select-Object Count, Name
```

---

## 17. Regras que merecem atenção inicial

No primeiro resultado do DNP3, algumas regras apareceram em grande quantidade:

```text
misra-c2012-17.3
misra-c2012-10.4
misra-c2012-17.7
misra-c2012-21.1
misra-c2012-7.4
misra-c2012-21.6
```

Interpretação inicial:

- `21.6`: uso de funções de entrada/saída da biblioteca padrão, como `printf`, `sprintf`, `snprintf`, `vsprintf`, etc.
- `17.7`: valor de retorno de função não usado.
- `17.3`: função usada sem declaração prévia visível, podendo indicar include/protótipo faltante.
- `10.4`: operações entre tipos essenciais diferentes.
- `7.4`: literais string e questões de const-correctness.
- `21.1`: identificadores ou macros possivelmente reservados.

Para o projeto DNP3, a regra `21.6` é especialmente relevante porque se conecta com a substituição de logs baseados em `sprintf`/`vsprintf` por uma arquitetura de diagnóstico estruturado.

---

## 18. Observações finais

Este fluxo não torna o projeto automaticamente MISRA-compliant.

Ele cria uma base operacional para:

1. executar análise estática de forma repetível;
2. registrar resultados fora da árvore Git do projeto;
3. separar Cppcheck normal de MISRA;
4. investigar includes e macros de forma objetiva;
5. gerar um baseline inicial;
6. iniciar triagem técnica das violações;
7. decidir o que será corrigido, justificado ou excluído por escopo.

Para projetos embarcados reais, principalmente com código gerado, HAL, RTOS e middleware de terceiros, a estratégia recomendada é começar pequeno:

```text
um arquivo
uma regra
uma categoria de problema
uma correção defensável
```

Depois expandir.
