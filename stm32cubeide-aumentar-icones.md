# Aumentar ícones e escala visual do STM32CubeIDE

Este procedimento ajusta a escala visual do STM32CubeIDE, deixando ícones e elementos da interface maiores.

No caso testado, a configuração que funcionou foi adicionar a opção abaixo no arquivo `STM32CubeIDE.ini`, depois da linha `-vmargs`:

```ini
-Dswt.autoScale=200
```

## Arquivo a editar

O arquivo de configuração é:

```text
STM32CubeIDE.ini
```

No Windows, ele normalmente fica dentro da pasta de instalação do STM32CubeIDE, por exemplo:

```text
C:\ST\STM32CubeIDE_x.y.z\STM32CubeIDE.ini
```

ou em uma pasta semelhante, dependendo da versão instalada.

## Procedimento

1. Feche o STM32CubeIDE.
2. Localize o arquivo `STM32CubeIDE.ini`.
3. Abra o arquivo em um editor de texto.
4. Localize a linha:

```ini
-vmargs
```

5. Adicione a linha abaixo **após** `-vmargs`:

```ini
-Dswt.autoScale=200
```

6. Salve o arquivo.
7. Abra novamente o STM32CubeIDE.

## Exemplo de trecho do arquivo

Um trecho típico do arquivo pode ficar assim:

```ini
-startup
plugins/org.eclipse.equinox.launcher_*.jar
--launcher.library
plugins/org.eclipse.equinox.launcher.win32.win32.x86_64_*
-vmargs
-Dswt.autoScale=200
-Xms256m
-Xmx2048m
```

## Ponto mais importante

A opção precisa ficar **depois de `-vmargs`**, pois ela é um argumento passado para a JVM/SWT usada pelo Eclipse/STM32CubeIDE.

Correto:

```ini
-vmargs
-Dswt.autoScale=200
```

Incorreto:

```ini
-Dswt.autoScale=200
-vmargs
```

Se a opção for colocada antes de `-vmargs`, o ajuste pode não funcionar.

## Valor usado

O valor que funcionou bem foi:

```ini
-Dswt.autoScale=200
```

Esse valor corresponde a uma escala de aproximadamente 200%.

Valores maiores podem não produzir efeito adicional ou podem causar problemas visuais, dependendo da versão do Eclipse/SWT usada pelo STM32CubeIDE.

## Caso a interface fique estranha

Se a interface apresentar problemas visuais após o ajuste, feche o STM32CubeIDE e remova a linha:

```ini
-Dswt.autoScale=200
```

Depois salve o arquivo e abra novamente o programa.

## Alternativa possível

Em algumas instalações baseadas em Eclipse/SWT, também pode existir a opção:

```ini
-Dorg.eclipse.swt.internal.deviceZoom=200
```

Porém, no caso testado, a opção que resolveu foi:

```ini
-Dswt.autoScale=200
```

Portanto, a recomendação inicial é usar apenas:

```ini
-Dswt.autoScale=200
```

## Resumo

Adicionar no arquivo `STM32CubeIDE.ini`, depois da linha `-vmargs`:

```ini
-Dswt.autoScale=200
```

Exemplo mínimo:

```ini
-vmargs
-Dswt.autoScale=200
```

