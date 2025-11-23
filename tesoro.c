#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Constantes del juego
#define MAX_TESOROS 3
#define MIN_TABLERO 20
#define MAX_TABLERO 120
#define MIN_DINERO 10
#define MAX_DINERO 100
#define MAX_AVANCE 6

// Variables globales
int tamano_tablero = 0;
int num_tesoros = 0;
int turno_actual = 1;

// Variables del jugador
int pos_jugador = 0;
int dinero_jugador = 0;
int tesoros_jugador = 0;

// Variables de la maquina
int pos_maquina = 0;
int dinero_maquina = 0;
int tesoros_maquina = 0;

int tablero[120];

// Prototipos
int validar_tamano();
int validar_movimiento();
void inicializar_tablero();
void mostrar_estado();
int lanzar_dado();
void procesar_movimiento(int avance, int es_jugador);
int verificar_fin();
void mostrar_resultados();

int main() {
    srand(time(NULL));
    
    printf("=== JUEGO DE LOS TESOROS ===\n");
    
    tamano_tablero = validar_tamano();

    num_tesoros = (tamano_tablero * 3) / 10;
    
    printf("\nTablero: %d casillas, Tesoros: %d\n", tamano_tablero, num_tesoros);
    printf("Objetivo: Encuentra %d tesoros o acumula mas dinero!\n\n", MAX_TESOROS);
    
    inicializar_tablero();
    
    // Bucle principal del juego
    while (1) {
        printf("\n=== TURNO %d ===\n", turno_actual);
        
        mostrar_estado();
        
        // Turno del jugador
        if (pos_jugador < tamano_tablero) {
            int avance = validar_movimiento();
            procesar_movimiento(avance, 1);
        }
        
        if (verificar_fin()) break;
        
        // Turno de la maquina
        if (pos_maquina < tamano_tablero) {
            int dado = lanzar_dado();
            printf("\nDado de la maquina: %d\n", dado);
            procesar_movimiento(dado, 0);
        }
        
        if (verificar_fin()) break;
        
        turno_actual++;
    }

    mostrar_resultados();
    
    return 0;
}

// Validar tamano del tablero
int validar_tamano() {
    int tamano;
    while (1) {
        printf("Ingrese tamano del tablero (20-120): ");
        scanf("%d", &tamano);
        
        if (tamano >= MIN_TABLERO && tamano <= MAX_TABLERO) {
            return tamano;
        }
        printf("Error: ingrese un numero entre 20 y 120\n");
    }
}

// Validar movimiento del jugador
int validar_movimiento() {
    int avance;
    while (1) {
        printf("\nIngrese avance (1-6): ");
        scanf("%d", &avance);
        
        if (avance >= 1 && avance <= MAX_AVANCE) {
            return avance;
        }
        printf("Error: ingrese un numero entre 1 y 6\n");
    }
}

// Inicializar tablero con dinero y tesoros
void inicializar_tablero() {
    int i;

    for (i = 0; i < tamano_tablero; i++) {
        tablero[i] = MIN_DINERO + rand() % (MAX_DINERO - MIN_DINERO + 1);
    }
    
    int tesoros_colocados = 0;
    while (tesoros_colocados < num_tesoros) {
        int pos = rand() % tamano_tablero;
        if (tablero[pos] != -1) {
            tablero[pos] = -1;
            tesoros_colocados++;
        }
    }
}

void mostrar_estado() {
    printf("JUGADOR - Posicion: %d Dinero: %d Tesoros: %d\n", 
           pos_jugador, dinero_jugador, tesoros_jugador);
    printf("MAQUINA - Posicion: %d Dinero: %d Tesoros: %d\n", 
           pos_maquina, dinero_maquina, tesoros_maquina);
}

//dado para la maquina
int lanzar_dado() {
    return 1 + rand() % MAX_AVANCE;
}

// Procesar movimiento de un jugador
// es_jugador: 1 = jugador, 0 = maquina
void procesar_movimiento(int avance, int es_jugador) {
    int *pos, *dinero, *tesoros;
    char *nombre;
    
    // Seleccionar variables segun jugador
    if (es_jugador) {
        pos = &pos_jugador;
        dinero = &dinero_jugador;
        tesoros = &tesoros_jugador;
        nombre = "JUGADOR";
    } else {
        pos = &pos_maquina;
        dinero = &dinero_maquina;
        tesoros = &tesoros_maquina;
        nombre = "MAQUINA";
    }
    
    *pos += avance;

    if (*pos >= tamano_tablero) {
        *pos = tamano_tablero;
        printf("\n%s llego al final!\n", nombre);
        return;
    }
    
    int contenido = tablero[*pos];
    
    if (contenido == -1) {
        (*tesoros)++;
        printf("\n%s encontro TESORO (Total: %d)\n", nombre, *tesoros);
    } else {
        *dinero += contenido;
        printf("\n%s obtuvo dinero: %d (Total: %d)\n", nombre, contenido, *dinero);
    }
    
    tablero[*pos] = 0;
}

// Verificar si el juego termino
// Retorna 1 si termina, 0 si continua
int verificar_fin() {
    if (tesoros_jugador >= MAX_TESOROS || tesoros_maquina >= MAX_TESOROS) {
        return 1;
    }

    if (pos_jugador >= tamano_tablero && pos_maquina >= tamano_tablero) {
        return 1;
    }

    return 0;
}


// Mostrar resultados finales y determinar ganador
void mostrar_resultados() {
    printf("\n\n=== FIN DEL JUEGO ===\n");

    printf("JUGADOR - Posicion: %d Dinero: %d Tesoros: %d\n", 
           pos_jugador, dinero_jugador, tesoros_jugador);
    printf("MAQUINA - Posicion: %d Dinero: %d Tesoros: %d\n", 
           pos_maquina, dinero_maquina, tesoros_maquina);

    printf("\nGANADOR: ");

    int dinero_total = dinero_jugador + dinero_maquina;

    if (tesoros_jugador >= MAX_TESOROS && tesoros_maquina < MAX_TESOROS) {
        printf("JUGADOR\n");
    }
    else if (tesoros_maquina >= MAX_TESOROS && tesoros_jugador < MAX_TESOROS) {
        printf("MAQUINA\n");
    }
    else {
        if (dinero_jugador > dinero_maquina) {
            printf("JUGADOR\n");
        }
        else if (dinero_maquina > dinero_jugador) {
            printf("MAQUINA\n");
        }
        else {
            if (tesoros_jugador > tesoros_maquina) {
                printf("JUGADOR\n");
            }
            else if (tesoros_maquina > tesoros_jugador) {
                printf("MAQUINA\n");
            }
            else {
                printf("EMPATE\n");
            }
        }
    }

    printf("El ganador se lleva un premio total de: %d\n", dinero_total);
    printf("\nGracias por jugar!\n");
}
