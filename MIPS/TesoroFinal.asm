# Juego de los Tesoros - VERSION FINAL FUNCIONAL
# Sin bucles infinitos - Probado y funcionando

.data
    msg_titulo: .asciiz "\n=== JUEGO DE LOS TESOROS ===\n"
    msg_tamano: .asciiz "Ingrese tamano del tablero (20-120): "
    msg_config: .asciiz "Tablero: "
    msg_tesoros_config: .asciiz " casillas | Tesoros: "
    msg_inicio: .asciiz "\nInicia el juego!\n"
    msg_sep: .asciiz "========================================\n"
    
    msg_turno: .asciiz "\n--- TURNO "
    msg_turno2: .asciiz " ---\n"
    msg_estado_j: .asciiz "JUGADOR - Pos: "
    msg_estado_m: .asciiz "MAQUINA - Pos: "
    msg_dinero: .asciiz " | Dinero: $"
    msg_tesoros: .asciiz " | Tesoros: "
    
    msg_ingreso: .asciiz "Tu movimiento (1-6): "
    msg_dado_maq: .asciiz "Dado maquina: "
    
    msg_tesoro: .asciiz "*** TESORO ENCONTRADO! ***\n"
    msg_obtuvo: .asciiz "Obtuvo: $"
    
    msg_error_tam: .asciiz "ERROR: Ingrese entre 20 y 120\n"
    msg_error_mov: .asciiz "ERROR: Ingrese entre 1 y 6\n"
    
    msg_fin: .asciiz "\n=== FIN DEL JUEGO ===\n"
    msg_ganador: .asciiz "GANADOR: "
    msg_jug: .asciiz "JUGADOR"
    msg_maq: .asciiz "MAQUINA"
    msg_premio: .asciiz "\nPremio total: $"
    msg_nl: .asciiz "\n"
    
    tamano: .word 0
    num_tesoros: .word 0
    turno: .word 1
    pos_j: .word 0
    dinero_j: .word 0
    tesoros_j: .word 0
    pos_m: .word 0
    dinero_m: .word 0
    tesoros_m: .word 0
    
    .align 2
    tablero: .space 480
    semilla: .word 12345

.text
.globl main

main:
    # Semilla con tiempo
    li $v0, 30
    syscall
    sw $a0, semilla
    
    li $v0, 4
    la $a0, msg_titulo
    syscall
    
pedir_tamano:
    li $v0, 4
    la $a0, msg_tamano
    syscall
    
    li $v0, 5
    syscall
    move $t0, $v0
    
    slti $t1, $t0, 20
    bne $t1, $zero, error_tamano
    slti $t1, $t0, 121
    beq $t1, $zero, error_tamano
    
    sw $t0, tamano
    
    # Calcular tesoros = (tamano * 3) / 10  (parte entera)
    move $t1, $t0          # t1 = tamano
    li   $t2, 3
    mul  $t3, $t1, $t2     # t3 = tamano * 3
    li   $t4, 10
    div  $t3, $t4          # LO = (tamano * 3) / 10
    mflo $t3               # t3 = (tamano * 3) / 10
    sw   $t3, num_tesoros
    
    li $v0, 4
    la $a0, msg_config
    syscall
    li $v0, 1
    lw $a0, tamano
    syscall
    li $v0, 4
    la $a0, msg_tesoros_config
    syscall
    li $v0, 1
    lw $a0, num_tesoros
    syscall
    li $v0, 4
    la $a0, msg_inicio
    syscall
    
    # Inicializar tablero
    jal init_tablero
    
    li $v0, 4
    la $a0, msg_sep
    syscall

bucle_juego:
    li $v0, 4
    la $a0, msg_turno
    syscall
    li $v0, 1
    lw $a0, turno
    syscall
    li $v0, 4
    la $a0, msg_turno2
    syscall
    
    li $v0, 4
    la $a0, msg_estado_j
    syscall
    li $v0, 1
    lw $a0, pos_j
    syscall
    li $v0, 4
    la $a0, msg_dinero
    syscall
    li $v0, 1
    lw $a0, dinero_j
    syscall
    li $v0, 4
    la $a0, msg_tesoros
    syscall
    li $v0, 1
    lw $a0, tesoros_j
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    li $v0, 4
    la $a0, msg_estado_m
    syscall
    li $v0, 1
    lw $a0, pos_m
    syscall
    li $v0, 4
    la $a0, msg_dinero
    syscall
    li $v0, 1
    lw $a0, dinero_m
    syscall
    li $v0, 4
    la $a0, msg_tesoros
    syscall
    li $v0, 1
    lw $a0, tesoros_m
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    lw $t0, pos_j
    lw $t1, tamano
    slt $t2, $t0, $t1
    beq $t2, $zero, turno_maquina
    
pedir_movimiento:
    li $v0, 4
    la $a0, msg_ingreso
    syscall
    
    li $v0, 5
    syscall
    move $t3, $v0
    
    slti $t4, $t3, 1
    bne $t4, $zero, error_movimiento
    slti $t4, $t3, 7
    beq $t4, $zero, error_movimiento
    
    move $a0, $t3
    li $a1, 1
    jal procesar_mov
    
    jal verificar_fin
    bne $v0, $zero, fin_juego
    
turno_maquina:
    lw $t0, pos_m
    lw $t1, tamano
    slt $t2, $t0, $t1
    beq $t2, $zero, incrementar_turno
    
    jal random_dado
    move $t3, $v0
    
    li $v0, 4
    la $a0, msg_dado_maq
    syscall
    li $v0, 1
    move $a0, $t3
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    move $a0, $t3
    li $a1, 2
    jal procesar_mov
    
    jal verificar_fin
    bne $v0, $zero, fin_juego
    
incrementar_turno:
    lw $t0, turno
    addi $t0, $t0, 1
    sw $t0, turno
    j bucle_juego

error_tamano:
    li $v0, 4
    la $a0, msg_error_tam
    syscall
    j pedir_tamano

error_movimiento:
    li $v0, 4
    la $a0, msg_error_mov
    syscall
    j pedir_movimiento

fin_juego:
    li $v0, 4
    la $a0, msg_fin
    syscall
    la $a0, msg_estado_j
    syscall
    li $v0, 1
    lw $a0, pos_j
    syscall
    li $v0, 4
    la $a0, msg_dinero
    syscall
    li $v0, 1
    lw $a0, dinero_j
    syscall
    li $v0, 4
    la $a0, msg_tesoros
    syscall
    li $v0, 1
    lw $a0, tesoros_j
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    li $v0, 4
    la $a0, msg_estado_m
    syscall
    li $v0, 1
    lw $a0, pos_m
    syscall
    li $v0, 4
    la $a0, msg_dinero
    syscall
    li $v0, 1
    lw $a0, dinero_m
    syscall
    li $v0, 4
    la $a0, msg_tesoros
    syscall
    li $v0, 1
    lw $a0, tesoros_m
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    li $v0, 4
    la $a0, msg_ganador
    syscall

    # 1) PRIORIDAD: 3 TESOROS

    lw $t0, tesoros_j
    lw $t1, tesoros_m

    # Si JUGADOR tiene >=3 y MAQUINA <3 -> gana JUGADOR
    slti $t2, $t0, 3          # t2 = 1 si tesoros_j < 3
    bne  $t2, $zero, check_maq_tesoros
    slti $t3, $t1, 3          # t3 = 1 si tesoros_m < 3
    bne  $t3, $zero, gana_jugador   # jugador>=3 y maquina<3

check_maq_tesoros:
    # Si MAQUINA tiene >=3 y JUGADOR <3 -> gana MAQUINA
    slti $t2, $t1, 3          # t2 = 1 si tesoros_m < 3
    bne  $t2, $zero, comparar_dinero
    slti $t3, $t0, 3          # t3 = 1 si tesoros_j < 3
    bne  $t3, $zero, gana_maquina   # maquina>=3 y jugador<3

comparar_dinero:
    # 2) Nadie llego a 3 tesoros -> decidir por DINERO
    lw $t0, dinero_j
    lw $t1, dinero_m
    slt $t2, $t1, $t0
    bne $t2, $zero, gana_jugador
    slt $t2, $t0, $t1
    bne $t2, $zero, gana_maquina

    # 3) Empate en dinero -> decidir por TESOROS
    lw $t0, tesoros_j
    lw $t1, tesoros_m
    slt $t2, $t1, $t0
    bne $t2, $zero, gana_jugador
    slt $t2, $t0, $t1
    bne $t2, $zero, gana_maquina

    # 4) Empate total -> por ahora dejamos que gane el jugador (o puedes crear un msg_empate)
    j gana_jugador


gana_maquina:
    li $v0, 4
    la $a0, msg_maq
    syscall
    j mostrar_premio

gana_jugador:
    li $v0, 4
    la $a0, msg_jug
    syscall

mostrar_premio:
    li $v0, 4
    la $a0, msg_premio
    syscall
    lw $t0, dinero_j
    lw $t1, dinero_m
    add $t0, $t0, $t1
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    li $v0, 10
    syscall
    
    
#cambiooooossssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss    

#???????????????????????????????????????????????????????????
# FUNCION: init_tablero - LLENA DINERO + TESOROS RANDOM
#???????????????????????????????????????????????????????????
# FUNCION: init_tablero - LLENA DINERO + TESOROS RANDOM
init_tablero:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    la $s0, tablero       # s0 = base de tablero
    lw $s1, tamano        # s1 = tamano
    li $s2, 0             # s2 = índice (0..tamano-1)
    
    # ====== PASO 1: llenar TODAS las casillas con dinero (10–100) ======
llenar_dinero:
    bge $s2, $s1, colocar_tesoros  # si s2 == tamano -> pasar a tesoros
    
    jal gen_dinero                  # v0 = dinero (10..100)
    
    sll $t0, $s2, 2                 # offset = s2 * 4
    add $t0, $s0, $t0               # &tablero[s2]
    sw $v0, 0($t0)                  # tablero[s2] = dinero
    
    addi $s2, $s2, 1
    j llenar_dinero

    # ====== PASO 2: colocar TESOROS aleatorios sin repetir casilla ======
colocar_tesoros:
    lw $s1, num_tesoros             # s1 = cantidad de tesoros a poner
    li $s2, 0                       # s2 = tesoros colocados = 0

loop_tesoros:
    beq $s2, $s1, fin_init          # si ya coloque todos -> fin

    # 1) generar número aleatorio grande
    jal gen_rand                    # v0 = random grande
    move $t0, $v0                   # t0 = random

    # 2) pos = random % tamano  usando DIV (rápido)
    lw  $t1, tamano                 # t1 = tamano
    div $t0, $t1                    # HI = t0 % tamano
    mfhi $t0                        # t0 = resto (0..tamano-1)

    # 3) &tablero[t0]
    sll $t4, $t0, 2                 # offset = t0 * 4
    add $t4, $s0, $t4               # &tablero[t0]
    lw  $t5, 0($t4)                 # leer contenido actual

    li  $t6, -1
    beq $t5, $t6, loop_tesoros      # si ya hay tesoro (-1), buscar otra posición

    # 4) colocar tesoro
    li  $t6, -1
    sw  $t6, 0($t4)

    # 5) siguiente tesoro
    addi $s2, $s2, 1
    j loop_tesoros

fin_init:
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra


    
  #FIN DE CAMBIOS  de intentar poner en posiciones random los tesoros    

#???????????????????????????????????????????????????????????
# FUNCION: procesar_mov
#???????????????????????????????????????????????????????????
procesar_mov:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    li $t9, 1
    beq $s1, $t9, mover_jugador
    
mover_maquina:
    lw $t0, pos_m
    add $t0, $t0, $s0
    lw $t1, tamano
    slt $t2, $t0, $t1
    beq $t2, $zero, maq_fin
    
    sw $t0, pos_m
    la $t3, tablero
    sll $t4, $t0, 2
    add $t4, $t3, $t4
    lw $t5, 0($t4)
    
    li $t6, -1
    beq $t5, $t6, maq_tesoro
    
    lw $t7, dinero_m
    add $t7, $t7, $t5
    sw $t7, dinero_m
    
    li $v0, 4
    la $a0, msg_obtuvo
    syscall
    li $v0, 1
    move $a0, $t5
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    move $s2, $t4
    j limpiar
    
maq_tesoro:
    lw $t7, tesoros_m
    addi $t7, $t7, 1
    sw $t7, tesoros_m
    
    li $v0, 4
    la $a0, msg_tesoro
    syscall
    
    move $s2, $t4
    j limpiar
    
maq_fin:
    sw $t1, pos_m
    j fin_proc


mover_jugador:
    lw $t0, pos_j
    add $t0, $t0, $s0
    lw $t1, tamano
    slt $t2, $t0, $t1
    beq $t2, $zero, jug_fin
    
    sw $t0, pos_j
    la $t3, tablero
    sll $t4, $t0, 2
    add $t4, $t3, $t4
    lw $t5, 0($t4)
    
    li $t6, -1
    beq $t5, $t6, jug_tesoro
    
    lw $t7, dinero_j
    add $t7, $t7, $t5
    sw $t7, dinero_j
    
    li $v0, 4
    la $a0, msg_obtuvo
    syscall
    li $v0, 1
    move $a0, $t5
    syscall
    li $v0, 4
    la $a0, msg_nl
    syscall
    
    move $s2, $t4
    j limpiar
    
jug_tesoro:
    lw $t7, tesoros_j
    addi $t7, $t7, 1
    sw $t7, tesoros_j
    
    li $v0, 4
    la $a0, msg_tesoro
    syscall
    
    move $s2, $t4
    j limpiar
    
jug_fin:
    sw $t1, pos_j
    j fin_proc
    
limpiar:
    sw $zero, 0($s2)
    
fin_proc:
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra

#???????????????????????????????????????????????????????????
# FUNCION: verificar_fin
#???????????????????????????????????????????????????????????
verificar_fin:
    lw $t0, tesoros_j
    slti $t1, $t0, 3
    beq $t1, $zero, ret_fin
    
    lw $t0, tesoros_m
    slti $t1, $t0, 3
    beq $t1, $zero, ret_fin
    
    lw $t0, pos_j
    lw $t1, pos_m
    lw $t2, tamano
    
    slt $t3, $t0, $t2
    bne $t3, $zero, ret_cont
    slt $t3, $t1, $t2
    bne $t3, $zero, ret_cont
    
ret_fin:
    li $v0, 1
    jr $ra
    
ret_cont:
    li $v0, 0
    jr $ra

#???????????????????????????????????????????????????????????
# GENERADORES ALEATORIOS
#???????????????????????????????????????????????????????????

gen_rand:
    lw $t0, semilla
    li $t1, 1103515245
    mult $t0, $t1
    mflo $t0
    addiu $t0, $t0, 12345
    sw $t0, semilla
    srl $v0, $t0, 1
    jr $ra

#cambio de gen dinero 

gen_dinero:
    addi $sp, $sp, -8      # reservar espacio en la pila
    sw   $ra, 0($sp)       # guardar $ra (retorno a quien llamo gen_dinero)
    sw   $t0, 4($sp)       # opcional: guardar $t0 si quieres dejarlo intacto

    jal  gen_rand          # v0 = número aleatorio grande

    li   $t0, 91           # 91 valores posibles (0–90)
    div  $v0, $t0          # v0 / 91
    mfhi $t1               # t1 = v0 % 91

    addi $v0, $t1, 10      # v0 = 10–100 (valor de dinero a devolver)

    lw   $t0, 4($sp)       # restaurar $t0 (opcional)
    lw   $ra, 0($sp)       # restaurar $ra (vuelta al caller correcto)
    addi $sp, $sp, 8       # liberar espacio en la pila

    jr   $ra               # volver a quien llamó gen_dinero


#fin de cambio

random_dado:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal gen_rand          # v0 = random grande
    li $t0, 6
    div $v0, $t0
    mfhi $t1              # residuo 0-5
    addi $v0, $t1, 1      # convertir 0-5 ? 1-6

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

