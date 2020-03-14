###########################
# Term Project, Phase 2 
# Implementation
# 2019-04-13

    .data
        city:   .word   0, 0, 8, 6, 2, 4, 6, 7, 1, 3, 9, 4, 2, 3
        #               c1    c2    c3    c4    c5    c6    c7
        dist:   .space  392
        #               double dist[7][7] : 8bytes * 7 * 7 = 392
        memory: .space  14336
        #               double memory[7][256] : 8bytes * 7 * 256
        parent: .space  7168
        #               int parent[7][256] : 4bytes * 7 * 256
        path:   .space  28
        #               int path[7] : 7 * 4bytes = 28

        msg_newLine:        .asciiz " \n"
        msg_travel_dist:        .asciiz "Shortest Path's Travel Distance : "
        msg_shortest_Path:      .asciiz "Destination of Shortest path : \n"
        msg_City:           .asciiz "[City "
        msg_rParen:     .asciiz "]"
        msg_arrow:      .asciiz " ->"
        msg_City1:      .asciiz "[City 1]"
        
    .text
    
main:       
            ##### INITIALIZE #####
            li          $v0,1           # system call code for print_int        
            move        $a0, $t8        # move value to be printed to $a0
            syscall
            
            

            li          $v0,1           # system call code for print_int        
            move        $a0, $t9        # move value to be printed to $a0
            syscall
        
            la      $s2, city
            la      $s3, dist
            la      $s4, memory
            la      $s5, parent
            la      $s6, path
jal     init            # set the argument to pass, to 3
                                    # jump to fact function
            
            ##### MAIN ROUTINE                                            #####
            
            ##### Pre-defineds                                            #####                     
            ##### TSP (int cur, char visited, int previous)               #####
            ##### $s2 city[][] $s3 dist[][] $s4 memory[][] $s5 parent[][] #####
            ##### $a1 int cur /$a2 char visited/ $a3 int previous         #####
            
            ##### Register Assignments                                    #####
            
            ##### $s0 - int next                                          #####
            ##### $f0 - store result, finally return this                 #####
            ##### $f2 - zero register for double                          #####
            ##### $f4 - dist[cur][next]                                   #####
            ##### $f6 - memory[cur][visited]                              #####
            ##### $f8 - sufficiently Big number in FP. 10000.             #####
            ##### $f10 - result of sub-problem, which is compared to $f0  #####
            
            li      $a1, 0                  # int cur
            li      $a2, 1                  # char visited
            li      $a3, 10                 # int previous
            
            li      $t1, 0x0
            li      $t2, 0x40C38800
            
            li      $t3, 0
            li      $t4, 0
            mtc1.d  $t3, $f0                # set $f0 to be 10000
            mtc1.d  $t3, $f2                # set $f2 to be 0
            mtc1.d  $t3, $f6                # set $f6 to be 0
            mtc1.d  $t1, $f8                # set $f8 to be 10000
            mtc1.d  $t3, $f10               # set $f10 to be 0
            

            mfc0        $t9,    $9

            li      $v0, 4                  # system call code for print_str
            la      $a0, msg_newLine        # message to print
            syscall
    
    
            ##### Call TSP    #####
            jal     TSP

            li      $v0, 4                  # system call code for print_str
            la      $a0, msg_travel_dist    # message to print
            syscall

            li      $v0, 3                  # system call code for print_float
            mov.d   $f12, $f0               # Move contents of register $f0 to register $f12
            syscall
li      $v0, 4                  # system call code for print_str
            la      $a0, msg_newLine        # message to print
            syscall

            li  $a1, 0

            ##### PRINT PATH  #####
            jal printPath
            
            ##### END PROGRAM #####
            

            li      $v0, 10         # set v0 = 10 to exit program
            syscall                 # system call to exit

            ##### INITIALIZE #####
init:       
            addi    $sp, $sp, -8
            sw      $s0, 4($sp)
            sw      $s1, 0($sp)
            li      $s0, 0          #init i = 0

L1:         
            li      $s1, 0          #init j = 0
            slti    $t0, $s0, 7
            bne     $t0, 0, L2
            j       init_Exit

L2:         
            slti    $t0, $s1, 7
            bne     $t0, 1, L2_Exit
            
            # find city information
            sll      $t1, $s0, 3      # 8 * i   city i+1
            sll      $t2, $s1, 3      # 8   * j   city j+1
            add      $t1, $s2, $t1   # address of city i+1.x
            add      $t2, $s2, $t2   # address of city j+1.x
                
            lwc1   $f2, 0($t1)      # i+1.x
            lwc1   $f4, 4($t1)      # i+1.y
            lwc1   $f6, 0($t2)      # j+1.x
            lwc1   $f8, 4($t2)      # j+1.y
         
            cvt.d.w $f2, $f2
            cvt.d.w $f4, $f4
            cvt.d.w $f6, $f6
            cvt.d.w $f8, $f8
         
            sub.d   $f2, $f2, $f6   # i+1.xpos - j+1.xpos
            sub.d   $f4, $f4, $f8   # i+1.ypos - j+1.ypos
            mul.d   $f2, $f2, $f2   # x diff ^2
            mul.d   $f4, $f4, $f4   # y diff ^2
            add.d   $f0, $f2, $f4   # type conversion

            sqrt.d  $f0, $f0
            
            # store
 addi    $t1, $s0, 0     # i
            sll     $t3, $s0, 1     # 2i
            add     $t1, $t1, $t3   # i + 2i
            sll     $t3, $t3, 1     # 4i
            add     $t1, $t1, $t3   # 7i
            sll     $t1, $t1, 3     # 7* 8 * i
            
            sll     $t2, $s1, 3     # 8 * j
            add     $t1, $t1, $t2   # [i][j]
            add     $t1, $s3, $t1   # double [i][j]
            s.d     $f0, 0($t1)     # store to [i][j]
            
            addi    $t1, $s1, 0     # j 
            sll     $t3, $s1, 1     # 2j
            add     $t1, $t1, $t3   # j + 2j
            sll     $t3, $t3, 1     # 4j
            add     $t1, $t1, $t3   # 7j
            sll     $t1, $t1, 3     # 7 * 8 * j
            
            sll     $t2, $s0, 3     # 8 * i
            add     $t1, $t1, $t2   # [j][i]
            add     $t1, $s3, $t1   # double [j][i]
            s.d     $f0, 0($t1)     # store to [j][i]
            
            # to loop
            addi    $s1, $s1, 1
            j       L2
            
L2_Exit:    
            addi    $s0, $s0, 1
            j       L1
        
init_Exit:  
            lw      $s0, 4($sp)
            lw      $s1, 0($sp)
            addi    $sp, $sp, 8
            jr      $ra

            ##### MAIN ROUTINE                                            ##### 
            
            ##### Pre-defineds                                            #####                     
            ##### TSP (int cur, char visited, int previous)               #####
            ##### $s2 city[][] $s3 dist[][] $s4 memory[][] $s5 parent[][] #####
            ##### $a1 int cur /$a2 char visited/ $a3 int previous         #####
            
            ##### Register Assignments                                    #####
            
            ##### $s0 - int next                                          #####
            ##### $f0 - store result, finally return this                 #####
            ##### $f2 - zero register for double                          #####
            ##### $f4 - dist[cur][next]                                   #####
            ##### $f6 - memory[cur][visited]                              #####
            ##### $f10 - candidate answer. It is compared to $f0          #####
            
TSP:        
            addi    $sp, $sp, -4    # get stack to store variable $s0 in TSP
            sw      $s0, 0($sp)     # store
addi    $s0, $zero, 0   # initialize int next = 0

Recursive_Call:         
            # Recursive Calls
            # Recursive Call Exit Conidtion
            
            # case1. check if visited = 01111111(2) = 127
            beq     $a2, 127, End_of_Tree

            # case2. check if the data already exists in memory[next][visited|(1<<next)]
            
            # check Exit condition first
            slti    $t0, $s0, 7
            beq     $t0, 0, Exit_TSP
            
            addi    $t0, $s4, 0     # memory
            
            addi    $t1, $s0, 0     # $t1 = next
            
            addi    $t3, $zero, 1   # $t3 = 1
            sllv    $t3, $t3, $t1   # 1 << next
            
            sll     $t1, $t1, 11    # $t1 = next << 11 = next * 256(for each row) * 8(bytes) :row

            addi    $t2, $a2, 0     # $t2 = visited
            
            or      $t2, $t2, $t3   # visited = visited | (1<<next)
            
            sll     $t2, $t2, 3 # $t2 = visited << 3 = visited * 8bytes :col
            
            add     $t0, $t0, $t1   # memory + next * 256 * 8 + 8 * visited
            add     $t0, $t0, $t2   
            
            ldc1    $f6, 0($t0)     # load memory[next][visited] to $f6
            c.eq.d  $f6, $f2        # if $f6 has value already been stored,( is not 0 )
            bc1f    Get_From_Memory # refer memory data. update, or not.
            
            # if data not exists, initialize.
            addi    $t0, $s4, 0     # memory
            
            addi    $t1, $a1, 0     # $t1 = cur
            sll     $t1, $t1, 11    # $t1 = cur << 11 = cur * 256(for each row) * 8(bytes) :row

            addi    $t2, $a2, 0     # $t2 = visited
            sll     $t2, $t2, 3     # $t2 = visited << 3 = visited * 8bytes :col
            
            add     $t0, $t0, $t1   # memory + cur * 256 * 8 + 8 * visited
            add     $t0, $t0, $t2   
            
            s.d     $f8, 0($t0)     # store 10000 in memory[cur][visited]
TSP_Loop:   
            slti    $t0, $s0, 7     # if next < 7 is not satisfied, adjust stack
            beq     $t0, 0, Adjust_Stack
            
            # Testing continue condition
            
            # 1. check if visited & 1<<next is true
            addi    $t0, $a2, 0         # $t0 = visited
            addi    $t1, $zero, 1       # $t1 = 1
            sllv    $t1, $t1, $s0       # $t1 = 1<<next
            and     $t0, $t0, $t1       # $t0 = visited & 1<<next
            
            bne     $t0, 0, TSP_Loop_continue
            
            # 2. check if dist[cur][next] == 0
            addi    $t1, $a1, 0     # $t1 = cur
            addi    $t2, $s0, 0     # $t2 = next
            
            # get dist[cur][next] : dist + cur * 7 * 8 + next * 8 
            
            addi    $t0, $s3, 0     # dist
            sll     $t1, $t1, 3     # cur * 8 
            addi    $t3, $zero, 7
            mul     $t1, $t1, $t3   # cur * 7 * 8
            
            sll     $t2, $t2, 3     # next * 8
            
            add     $t0, $t0, $t1   # $t0 : dist + cur*7*8
            add     $t0, $t0, $t2   # $t0 : dist + cur*7*8 + next * 8
            
            ldc1    $f4, 0($t0)     # load $f4 = dist[cur][next]
            c.eq.d  $f4, $f2            # if $f4 is 0,
            bc1t    TSP_Loop_continue   # exit
            
            # Test Passes; step further to next recursion case
            # test passes, than recursive call
            # Store variables : (bottom) cur, visited, prev, next, dist (top)
            #                            4B   4B       4B    4B    8B
            addi    $sp, $sp, -24
            sw      $a1, 20($sp)    # cur
            sw      $a2, 16($sp)    # visited
            sw      $a3, 12($sp)    # prev
            sw      $s0, 8($sp)     # next
            s.d     $f4, 0($sp)     # store dist[cur][next]
            
            # Reset variables
            
            lw      $a1, 8($sp)     # cur = next
            
            addi    $t0, $zero, 1   # $t0 = 1
            sllv    $t0, $t0, $a1   # $t0 = 1<<next
            or      $a2, $a2, $t0   # visited = visited | (1<<next)
            
            lw      $a3, 20($sp)    # prev = cur;
 addi    $s0, $zero, 0   # initialize int next = 0
            
            j       Recursive_Call
            
TSP_Loop_continue:  
            addi    $s0, $s0, 1
            j       TSP_Loop

End_of_Tree:
            addi    $t1, $a1, 0     # $t1 = cur
            addi    $t2, $a2, 0     # $t2 = visited
            
            # 1. Get dist[cur][0]
            # return dist[cur][0] : dist + cur * 7 * 8 
            addi    $t0, $s3, 0     # dist
            sll     $t1, $t1, 3     # cur * 8 
            addi    $t2, $zero, 7
            mul     $t1, $t1, $t2   # cur * 7 * 8
            add     $t0, $t0, $t1   # $t0 : dist + cur*7*8
            
            # 2. Set data to Memorize. 
            ldc1    $f4, 0($t0)     # load dist[cur][0] to $f4  

            # 3. Record path information
            # parent[cur][visited] = previous
            addi    $t0, $s5, 0     # parent
            addi    $t1, $a1, 0     # $t1 = cur
            sll     $t3, $t1, 10    # $t3 = cur << 10 = cur * 256(for each row) * 4(bytes) :row
            sll     $t4, $t2, 2     # $t4 = visited << 2 = visited * 8bytes :col
            
            # parent + cur * 256 * 4 + 4 * visited
            add     $t0, $t0, $t3   
            add     $t0, $t0, $t4   
            # store previous
            sw      $a3, 0($t0)
            
            # 4. update to memory[cur][visited]
            addi    $t0, $s4, 0             # memory
            
            addi    $t1, $a1, 0             # $t1 = cur
            sll     $t1, $t1, 11            # $t1 = cur << 11 = cur * 256(for each row) * 8(bytes) :row
            
            addi    $t2, $a2, 0             # $t2 = visited
            sll     $t2, $t2, 3             # $t2 = visited << 3 = visited * 8bytes :col
            
            add     $t0, $t0, $t1           # memory + cur * 256 * 8 + 8 * visited
            add     $t0, $t0, $t2   
                
            s.d     $f4, 0($t0)         # just update
            
            j       Adjust_Stack        # check exit condition

Get_From_Memory:
 # In this case, need to compare
            # memory[cur][visited] : stored data ... to $f0
            # dist[cur][next] + memory[next][visited|1<<next] ... to $f10
            
            # 1. store memory[cur][visited] to $f0
            
            addi    $t0, $s4, 0     # memory
            
            addi    $t1, $a1, 0     # $t1 = cur
            sll     $t1, $t1, 11    # $t1 = cur << 11 = cur * 256(for each row) * 8(bytes) :row

            addi    $t2, $a2, 0     # $t2 = visited
            sll     $t2, $t2, 3     # $t2 = visited << 3 = visited * 8bytes :col
            
            add     $t0, $t0, $t1   # memory + cur * 256 * 8 + 8 * visited
            add     $t0, $t0, $t2   
            
            ldc1    $f0, 0($t0)     # load memory[cur][visited] to $f0
            
            # 2. get dist[cur][next] + memory[next][visited|1<<next] to $f10
            # $f10 already has dist[cur][next]
            # $f6 already has memory[next][visited|1<<next]
            
            add.d   $f10, $f10, $f6 # add data in memory to update

            # 3. compare $f10, $f0
            # if less than memory, update ; $f10 has candidate solution
            
            c.le.d  $f10, $f0               # Is $f10 < $f0?
            bc1f    Memory_Ref_Done         # If that is false, skip. 
            
            # else, 
            # 3-1. update. 
            # note that $t0 already has the address of memory[cur][visited]
            s.d     $f10, 0($t0)
            
            # 3-2. update parent info
            # that is, parent[cur][visited] = next
            addi    $t0, $s5, 0     # parent
            addi    $t1, $a1, 0     # $t1 = cur
            addi    $t2, $a2, 0     # $t2 = visited
            
            sll     $t3, $t1, 10    # $t3 = cur << 10 = cur * 256(for each row) * 4(bytes) :row
            sll     $t4, $t2, 2 # $t4 = visited << 2 = visited * 4bytes :col
            
            add     $t0, $t0, $t3   # parent + cur * 256 * 4 + 4 * visited
            add     $t0, $t0, $t4   
            
            sw      $s0, 0($t0)     # store next
            
            
Memory_Ref_Done:
# memory reference is done.
            # that is,
            # we don't need to think more about current subcase.
            # so add 1 to next, to move on.
            
            addi    $s0, $s0, 1
            j       TSP_Loop

Adjust_Stack:
            # if next >=0, adjust stack. 
            beq     $a1, 0, Exit_TSP
            lw      $a1, 20($sp)    # cur
            lw      $a2, 16($sp)    # visited
            lw      $a3, 12($sp)    # prev
            lw      $s0, 8($sp)     # next
            ldc1    $f10, 0($sp)    # load distance 1 stage before
            
            addi    $sp, $sp, 24    # adjust stack
            
            j       Recursive_Call
                        
Exit_TSP:
            # finally, return memory[0][1]
            addi    $t0, $s4, 0     # memory
            
            addi    $t1, $zero, 0
            sll     $t1, $t1, 11    # $t1 = cur << 11 = cur * 256(for each row) * 8(bytes) :row
            
            addi    $t2, $zero, 1
            sll $t2, $t2, 3     # $t2 = visited << 3 = visited * 8bytes :col
            
            add     $t0, $t0, $t1   # memory + cur * 256 * 8 + 8 * visited
            add     $t0, $t0, $t2   
            
            ldc1    $f0, 0($t0)     # load memory[cur][visited] to $f0
            
            addi    $sp, $sp, 4     # adjust stack for $s0. 
            
            jr      $ra

printPath:
        ##### Register Assignments
        ##### $s0 - start
        ##### $s1 - idx
        ##### $s2 - pred
        ##### $s3 - visited
        ##### $s7 - k (loop counter / recycled 3 times)
    
        ##### Predefined, used in printPath()
        ##### $s5 - int parent[7][256]
        ##### $s6 - int path[7]
    

        addi    $sp, $sp, -20
sw      $s0, 16($sp)
        sw      $s1, 12($sp)
        sw      $s2, 8($sp)
        sw      $s3, 4($sp)
        sw      $s7, 0($sp)
    
        li      $s0, 0          # start = 0
        li      $s1, 0          # idx = 0

        sll     $t1, $s1, 2     # 4 * idx ( int path[] / need 4bytes)
        add     $t1, $s6, $t1   # path[idx]
        li      $t2, 0
        sw      $t2, 0($t1)     # path[idx]=0
        addi    $s1, $s1, 1     # idx++

        li      $s2, 1          # pred = 1
        li      $s3, 1          # char visited = 1
        li      $s7, 0          # k = 0 

loop_1:
        slti    $t0, $s7, 7
        beq     $t0, 0, exit_loop_1     # Condition1 : end iteration when k>=7

        beq     $s3, 127, exit_loop_1   # Condition2 : end iteration when visited = 01111111

        #get address of parent[start][visited]
        sll     $t0, $s0, 10            # start = 256(row) * 4 bytes (2^10)
        sll     $t1, $s3, 2             # visited = visited * 4 bytes
        add     $t0, $t0, $t1
        add     $t0, $s5, $t0           # parent[start][visited]
        lw      $s2, 0($t0)             # pred = parent[start][visited]

        sll     $t1, $s1, 2             # idx = idx * 4bytes
        add     $t1, $s6, $t1           # path[idx]
        sw      $s2, 0($t1)             # path[idx] = pred;
        addi    $s1, $s1, 1             # idx++
        
        #update visited
        addi    $t0, $zero, 1           # $t0 = 1
        sllv    $t0, $t0, $s2           # $t0 = 1<<pred 
        or      $s3, $s3, $t0           # visited = visited | 1<<pred
    
        add     $s0, $zero, $s2         # start = pred
        addi    $s7, $s7, 1             # k++
        j   loop_1

exit_loop_1 :
        # printf("Destination of the Shortest Path")
        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_shortest_Path  # message to print
        syscall 

        li      $s7, 0                  # k = 0 (in original code, it was 'i')

loop_2 : 
        slti    $t0, $s7, 7
        beq     $t0, 0, exit_loop_2
#get int path[k]
        sll     $t1, $s7, 2             # k = 4 * k (byte)
        add     $t1, $s6, $t1           # path[k]
        lw      $t2, 0($t1)             # $t2 = path[k]
        addi    $t2, $t2, 1             # $t2 = path[k] + 1

        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_City           # message to print "[City"
        syscall

        li      $v0, 1                  # system call code for print_int        
        move    $a0, $t2                # move value to be printed to $a0
        syscall

        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_rParen         # message to print "]"
        syscall
    
        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_arrow          # message to print "->"
        syscall
    
        addi    $s7, $s7, 1             # k++ (increment k)
        j   loop_2
    
exit_loop_2 :
        # print"[City 1]\n"
        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_City1          # message to print "[City"
        syscall
    
        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_newLine        # message to print "\n"
        syscall
        syscall

        # print"[City 1]"
        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_City1          # message to print "[City"
        syscall
    
        #start of new loop
        li      $s7, 6                  # k = 6 (in original code, it was 'i')

loop_3 :
        slti    $t0, $s7, 0             # set less than k<0
        beq     $t0, 1, exit_loop_3
    
        #get int path[k]
        sll     $t1, $s7, 2             # k = 4 * k (byte)
        add     $t1, $s6, $t1           # path[k]
        lw      $t2, 0($t1)             # $t2 = path[k]
        addi    $t2, $t2, 1             # $t2 = path[k] + 1

        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_arrow          # message to print "->"
syscall

        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_City           # message to print "[City"
        syscall

        li      $v0, 1                  # system call code for print_int        
        move    $a0, $t2                # move value to be printed to $a0
        syscall

        li      $v0, 4                  # system call code for print_str
        la      $a0, msg_rParen         # message to print "]"
        syscall

        addi    $s7, $s7, -1            # k-- (decrement k)
        j   loop_3

exit_loop_3 :
        #stack adjust
        lw      $s0, 16($sp)
        lw      $s1, 12($sp)
        lw      $s2, 8($sp)
        lw      $s3, 4($sp)
        lw      $s7, 0($sp)
        addi    $sp, $sp, 20
        jr      $ra
