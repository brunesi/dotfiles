# Micro + LSP para C/C++ com clangd

Guia pessoal para instalar o editor **Micro**, instalar o plugin **LSP** e configurar suporte a **C/C++** usando **clangd**.

Ambiente de referência: Ubuntu / WSL Ubuntu / Linux desktop.

---

## 1. Instalar o Micro via `curl`

Instalação local, no diretório atual:

```bash
curl https://getmic.ro | bash
```

Normalmente prefiro deixar o binário em um diretório global do sistema:

```bash
cd /usr/bin
curl https://getmic.ro | sudo sh
```

Alternativa com registro no `update-alternatives`, para que programas como `crontab -e` possam usar o Micro como editor do sistema:

```bash
cd /usr/bin
curl https://getmic.ro/r | sudo sh
```

Verificar:

```bash
micro -version
which micro
```

---

## 2. Instalar ferramentas básicas de C/C++

```bash
sudo apt update
sudo apt install build-essential clang clangd
```

Verificar:

```bash
gcc --version
clang --version
clangd --version
```

Em algumas versões do Ubuntu, pode existir um pacote versionado, por exemplo `clangd-18`, `clangd-17`, `clangd-16`, etc. Se o comando `clangd` não existir depois da instalação, verificar:

```bash
ls /usr/bin/clangd*
```

Se houver apenas uma versão específica, por exemplo `/usr/bin/clangd-18`, registrar como alternativa padrão:

```bash
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100
```

Depois confirmar:

```bash
clangd --version
```

---

## 3. Instalar o plugin LSP do Micro

```bash
micro -plugin install lsp
```

O plugin fica normalmente em:

```text
~/.config/micro/plug/lsp
```

---

## 4. Configurar `settings.json` do Micro

Arquivo:

```bash
micro ~/.config/micro/settings.json
```

Configuração mínima recomendada para C e C++:

```json
{
    "colorscheme": "cmc-16",
    "tabsize": 4,
    "tabstospaces": true,
    "eofnewline": true,
    "rmtrailingws": true,
    "lsp.server": "c=clangd,c++=clangd",
    "lsp.formatOnSave": false,
    "lsp.tabcompletion": true,
    "lsp.autocompleteDetails": false
}
```

Observações:

- `c=clangd,c++=clangd` associa o mesmo servidor LSP aos arquivos C e C++.
- `clangd` atende C, C++, Objective-C e Objective-C++.
- `formatOnSave` foi deixado como `false` para evitar que o editor reformate automaticamente código legado ou de projeto embarcado.
- `cmc-16` é o esquema de cores que eu gostei no Micro, incluindo boa visualização de parênteses/chaves.

---

## 5. Teste rápido

Criar um arquivo:

```bash
micro teste.c
```

Conteúdo:

```c
#include <stdio.h>

int main(void)
{
    int i = -1;
    unsigned int u;
    double d = 3.14;
    int j;
    char c;

    u = i;      /* signed -> unsigned */
    j = d;      /* double -> int */
    c = 1000;   /* int -> char, possivelmente truncado */

    printf("u = %u\n", u);
    printf("j = %d\n", j);
    printf("c = %d\n", c);

    return 0;
}
```

Compilar manualmente com warnings fortes:

```bash
clang -std=c17 -Wall -Wextra -Wconversion -Wsign-conversion teste.c -o teste
```

Ou com GCC:

```bash
gcc -std=c17 -Wall -Wextra -Wconversion -Wsign-conversion teste.c -o teste
```

Abrindo esse arquivo no Micro, o LSP via `clangd` deve começar a mostrar diagnósticos semelhantes aos do compilador/Clang.

Exemplo de diagnóstico esperado:

```text
implicit conversion changes value from 1000 to -24
```

Esse aviso aparece porque `1000` é uma constante conhecida em tempo de análise, e `char`, no ambiente usual, é um inteiro de 8 bits com sinal. Assim, o valor não cabe no tipo de destino.

---

## 6. Melhorar a análise do `clangd` com flags de compilação

Para arquivos simples, o `clangd` consegue trabalhar com uma configuração padrão. Para projetos reais, especialmente embarcados, ele precisa saber os mesmos includes, defines e flags usados na compilação real.

Existem duas formas comuns.

### 6.1. `compile_flags.txt`

Na raiz do projeto:

```bash
micro compile_flags.txt
```

Exemplo simples:

```text
-std=c17
-Wall
-Wextra
-Wconversion
-Wsign-conversion
-I./Inc
-I./App
-DSTM32U5A5xx
```

Esse método é simples e útil para estudos, MVPs e projetos pequenos.

### 6.2. `compile_commands.json`

Para projetos maiores, o ideal é gerar um `compile_commands.json`, que descreve como cada arquivo é compilado.

Em projetos CMake:

```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S . -B build
```

Depois, se necessário:

```bash
ln -s build/compile_commands.json compile_commands.json
```

Para projetos com Makefile, existem ferramentas como `bear`:

```bash
sudo apt install bear
bear -- make
```

Isso pode gerar um `compile_commands.json` a partir da compilação observada.

---

## 7. Comandos úteis dentro do Micro

Instalar plugin:

```text
Ctrl-e
plugin install lsp
```

Ou pelo terminal:

```bash
micro -plugin install lsp
```

Abrir ajuda:

```text
Ctrl-e
help
```

Ver opções:

```text
Ctrl-e
help options
```

Configurar opção diretamente no Micro:

```text
Ctrl-e
set tabsize 4
```

---

## 8. Atalhos do plugin LSP

O plugin LSP tenta registrar alguns atalhos automaticamente:

```text
Alt-k       hover / informação sobre símbolo
Alt-d       ir para definição
Alt-f       formatar
Alt-r       referências
Ctrl-space  completion
```

Dependendo do terminal, do tmux e dos bindings locais, alguns atalhos podem não chegar corretamente ao Micro.

---

## 9. Diagnóstico quando não funcionar

### 9.1. Verificar se o Micro existe

```bash
which micro
micro -version
```

### 9.2. Verificar se o plugin está instalado

```bash
ls ~/.config/micro/plug/lsp
```

### 9.3. Verificar se o `clangd` existe

```bash
which clangd
clangd --version
```

### 9.4. Verificar tipo de arquivo detectado pelo Micro

Abrir um arquivo `.c` ou `.cpp` e observar a statusline do Micro. O filetype deve aparecer como `c` ou `c++`.

### 9.5. Rodar compilação manual com warnings

```bash
clang -std=c17 -Wall -Wextra -Wconversion -Wsign-conversion teste.c -o teste
```

Se o compilador mostra warnings, mas o Micro não mostra nada, o problema provavelmente está na ligação Micro → plugin LSP → clangd.

Se nem o compilador entende corretamente o projeto, falta informar includes/defines/flags por `compile_flags.txt` ou `compile_commands.json`.

---

## 10. Nota sobre o meu `settings.json` final

Este guia inclui uma configuração base funcional e alinhada ao que eu uso: Micro, tema `cmc-16`, indentação com 4 espaços e LSP com `clangd` para C/C++.

Ainda falta conferir contra o meu `settings.json` final completo, caso exista uma versão mais elaborada com outros ajustes pessoais, plugins e bindings.  

## 11. Linha única para compilar e rodar  

Essa linha serve para dar o nome do arquivo, rodar o gcc com opções e já executar.

```
name=file2; gcc "${name}.c" -std=c17 -Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -o "$name" && ./"$name"
```

