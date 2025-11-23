# Juego de los Tesoros

Un juego de consola desarrollado en C donde compiten **el jugador** y **la máquina** por encontrar tesoros ocultos en un tablero unidimensional.  
Cada casilla contiene dinero o un tesoro, y ambos avanzan por turnos hasta que alguien gana.

## Objetivo del juego

Ganar encontrando **3 tesoros**  o, si nadie lo logra, acumulando **más dinero** al finalizar el recorrido.

## Reglas del Juego

1. El usuario elige el tamaño del tablero (entre **20 y 120** casillas).  
2. El número de tesoros equivale al **30%** del tamaño del tablero.  
3. Las casillas restantes contienen dinero aleatorio entre **$10 y $100**.  
4. El jugador avanza ingresando un número entre **1 y 6**.  
5. La máquina avanza con un dado aleatorio entre **1 y 6**.  
6. En cada turno se muestran posiciones, dinero acumulado y tesoros obtenidos.  
7. El juego termina cuando:
   - Un jugador encuentra **3 tesoros**, o  
   - Ambos llegan al final del tablero.
8. Si nadie obtiene 3 tesoros:
   - Gana el que tenga **más dinero acumulado**.  
   - Si hay empate en dinero, gana el que tenga **más tesoros**.  
   - Si sigue empatado: **empate total**.
9. El ganador se lleva **la suma del dinero** de ambos jugadores.

## Compilación

***EN MIPS:***

Asegúrate de tener instalado **MARS4.5** o algun otro compilador de ensamblador.

Descarga el archivo que está dentro de la carpeta MIPS "TesoroFinal.asm" dando a ctrl+shift+s o a los tres puntos y download:
[**TesoroFinal.asm**](https://github.com/CrisPih/Juego-Tesoros/blob/main/MIPS/TesoroFinal.asm)
Luego en tu simulador elegido le das a:

file -> open -> TesoroFinal.asm -> Assemble file -> run

***EN LENGUAJE C:***

Asegúrate de tener instalado **GCC** o alguna maquina virtual que compile C.

Para compilar el programa:

```bash
gcc tesoro.c -o tesoro.exe
```

Debes luego ejecutar:

```bash
.\tesoro.exe

