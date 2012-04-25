.data
	.align 2
	.globl BOARD
	BOARD:	.space 512
	.globl X
	X:	.word 0
	.globl Y
	Y:	.word 0
    .globl PX
    PX: .word 0
    .globl PY
    PY: .word 0
	newline:		.asciiz "\n"

	.text

.globl main
main:				#main has to be a global label
	addu	$s7, $0, $ra	#save the return address in a global register

	jal		INITBOARD				# jump to INITBOARD
#	jal		PRINTBOARD				# jump to PRINTBOARD
	jal		UPDATEBOARD				# jump to UPDATEBOARD

	li		$v0, 10			# Syscall to end program
	syscall

.globl INITBOARD
INITBOARD:
	add $t0, $zero, $zero
	sw $t0, X
	sw $t0, Y
	la $t0, BOARD		#current position in array
	addi $t1, $zero, 512		#counter for loop

	loopinit:
		sw $zero, ($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, -4
		bne $t1, $zero, loopinit
		jr $ra

.globl GETINCREMENT	#returns value at x,y to $v0
GETINCREMENT:			#return 1 to $v1 if increment move past valid x,y values, else it return 0
	lw $t0, Y
	lw $t1, X
	sll $t0, $t0, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $t1	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of current position
	lw $v0, ($t0)		#returns value at x,y
	lw $t0, X			#loading x so 	it can be incremented
	addi $t0, $t0, 1	#increment x
	addi $t1, $zero, 8
	blt $t0, $t1, skipincx	#check if we moved past the last column
	move $t0, $zero		#move to first column in next row
	sw $t0, X			#save new value of x
	lw $t0, Y			#loading y so it can be incremented
	addi $t0, $t0, 1	#increment y
	addi $t1, $zero, 16
	blt $t0, $t1, skipincy
	sw $zero, Y
	addi $v1, $zero, 1	#return 1 in $v1 to signal that you moved past the last row and column
	j	fin

	skipincx:
		sw $t0, X
		move $v1, $zero
		j	fin

	skipincy:
		sw $t0, Y
		move $v1, $zero
		j	fin				# jump to fin


	fin:
		jr $ra

.globl GETXY			#returns value at x,y to $v0
GETXY:
	lw $t0, Y
	lw $t1, X
	sll $t0, $t0, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $t1	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of current position
	lw $v0, ($t0)		#returns value at x,y
	jr $ra

.globl GETARGXY			# $a0=x, $a1=y, $v0=return value
GETARGXY:
	add $t0, $zero, $a1
	add $t1, $zero, $a0
	sll $t0, $t0, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $t1	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of current position
	lw $v0, ($t0)		#returns value at x,y
	jr $ra

.globl SETXY			#$a0=x, $a1=y, $a2=number to be stored
SETXY:
	sll $t0, $a1, 3		#multiply y by 8 to get to correct row
	add $t0, $t0, $a0	#add x to move to correct column within row
	sll $t0, $t0, 2		#mult by 4 to convert from index(words) to bytes
	la $t1, BOARD		#load address of BOARD to $t1
	add $t0, $t0, $t1	#address of inputted x,y
	sw $a2, ($t0)		#stores value to x,y
	jr $ra

.globl NEXT			#return 1 to $v0 if increment move past valid x,y values, else it return 0
NEXT:
	lw $t0, X			#loading x so it can be incremented
	addi $t0, $t0, 1	#increment x
	addi $t1, $zero, 8
	blt $t0, $t1, skipincxx	#check if we moved past the last column
	move $t0, $zero		#move to first column in next row
	sw $t0, X			#save new value of x
	lw $t0, Y			#loading y so it can be incremented
	addi $t0, $t0, 1	#increment y
	addi $t1, $zero, 16
	blt $t0, $t1, skipincyy
	sw $zero, Y
	addi $v0, $zero, 1	#return 1 in $v0 to signal that you moved past the last row and column
	j	finn

	skipincxx:
		sw $t0, X
		move $v0, $zero
		j	fin

	skipincyy:
		sw $t0, Y
		move $v0, $zero

	finn:
		jr $ra

.globl RESET			#resets x and y to 0
RESET:
	sw $zero, X
	sw $zero, Y
	jr $ra

.globl GETX			#returns the value of x to $v0
GETX:
	lw $v0, X
	jr $ra

.globl GETY			#returns the value of y to $v0
GETY:
	lw $v0, Y
	jr $ra


# This procedure jumps our global variables to the next line
# Returns 0 in $v0 if successful and 1 if not
.globl NEXTROW
NEXTROW:
	lw		$t0, Y			#
	sw		$zero, X		#
	addi	$t0, $t0, 1			    # $t0 = $t0 + 1
	addi	$t1, $zero, 16			# $t2 = $zero + 16
	blt		$t0, $t1, skiprowinc	# if $t0 < $t1 then skiprowinc
	sw		$zero, Y		#
	addi	$v0, $zero, 1			# $v0 = $zero + 1
	j		finrowinc				# jump to finrowinc

	skiprowinc:
		sw		$t0, Y		#
		add		$v0, $zero, $zero		# $v0 = $zero + $zero
		j		finrowinc				# jump to finrowinc

	finrowinc:
		jr		$ra					# jump to $ra

.globl PRINTBOARD
PRINTBOARD:
	sw		$ra, 0($sp)		# Store return address onto the stack

	j		printloop				# jump to printloop

	# This is actually printing the board
	printloop:

		jal		GETINCREMENT	# jump to GETINCREMENT and save position to $ra
		addi	$t1, $zero, 1			# $t0 = $zero + 1

		add		$t4, $v1, $zero		# $t4 = $v1 + $zero

		add		$a0, $zero, $v0		# $a0 = $zero + $v0
		li		$v0, 1		# system call #4 - print string
		syscall				# execute

		# This is our test to see if we still have more board spaces to print
		addi	$t1, $zero, 1			# $t1 = $zero + 1
		beq		$t4, $t1, finprint	# if $v1 == $t0 then finprint

		j printloop

	finprint:

		li		$v0, 4		# system call #4 - print string
		la		$a0, newline	# $a0 = $zero + 15
		syscall				# execute

		lw		$ra, 0($sp)			# Pop our return address off the stack
		jr		$ra					# jump to $ra

# This routine will read in code from STDIN and update our board
.globl UPDATEBOARD
UPDATEBOARD:
	# Print the board
	jal		PRINTBOARD				# jump to PRINTBOARD and save position to $ra

	# We want to load the board so we can update it with the new info from Python
	la		$t3, BOARD		# Load the address of the board

	updateloop:

        # Print an 8 to Python to prompt for new piece
        li        $a0, 8        # $a0 = 8
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

		# Load the interger input into a register
		add		$t2, $zero, $v0		# $t2 = $zero + $v0

		# Determine which piece needs to be created
		addi	$t0, $zero, 1			# $t0 = $zer0 + 1
		beq		$t0, $t2, CREATEP	# if $t0 == $t2 then CREATEP
		
		addi	$t0, $zero, 2			# $t0 = $zero + 2	
		beq		$t0, $t2, CREATES	# if $t0 == $t2 then CREATES
		
		addi	$t0, $zero, 3			# $t0 = $zero + 3	
#		beq		$t0, $t2, CREATEZ	# if $t0 == $t2 then CREATEZ

		addi	$t0, $zero, 4			# $t0 = $zero + 4
#		beq		$t0, $t2, CREATEBZ	# if $t0 == $t2 then CREATEBZ

		addi	$t0, $zero, 5			# $t0 = $zero + 5
		beq		$t0, $t2, CREATEL	# if $t0 == $t2 then CREATEL

		addi	$t0, $zero, 6			# $t0 = $zero + 6
#		beq		$t0, $t2, CREATEBL	# if $t0 == $t2 then CREATEBL

		addi	$t0, $zero, 7			# $t0 = $zero + 7
#		beq		$t0, $t2, CREATET	# if $t0 == $t2 then CREATET

		# If we receive a 9 from Python, jump to the end
		addi	$t0, $zero, 9		# $t0 = $zero + 9
		beq		$t0, $t2, finupdate	# if $t0 == $t2 then finupdate

		# Jump back up to wait for more input from Python
		j finupdate

	# This routine is for when we are finished hearing from Python
	finupdate:

		j		GAMEOVER				# jump to GAMEOVER


.globl CREATEP
CREATEP:

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

    # Store the value for safe keeping
    sw      $t0, PX        #
    sw      $t1, PY        #

	# Store the first position of the board
	addi	$t2, $zero, 1		# $t1 = $zero + 1
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	add		$a2, $zero, $t2		# $a2 = $zero + $t2
	jal		SETXY				# jump to SETXY and save position to $ra

	# $t9 holds the rotation state. 1 for vertical, 2 for horizontal
	addi	$t9, $zero, 1			# $t7 = $zero + 1

    # Start the piece loop
    j        ploop                # jump to ploop


	ploop:

        # We want to print our board back to Python
        jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# A counter for moving pieces
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 2 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 2
		beq		$v0, $t3, shiftpl	# if $v0 == $t3 then shiftpl

		# If Python sends us a 1 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 1
		beq		$v0, $t3, shiftpr	# if $v0 == $t3 then shiftpr

		# If Python sends us a 3 then we want to rotate the piece
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq		$v0, $t3, rotatep	# if $v0 == $t3 then target

		# If our piece is in position 1 then drop vertical
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, droppv	# if $t9 == $t3 then droppv

		# If our piece is in position 2 then drop horizontal
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, dropph	# if $t9 == $t3 then dropph

		# If we get here something is wrong so we wait for another input
		j		ploop				# jump to ploop

	shiftpr:

		# Load our X and Y values
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We add one to our PX-value for testing purposes
		addi	$t0, $t0, 1			# $t0 = $t0 + 1

		# We need a counter initialized for looping purposes
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If $t9 == 1 then the pipe is vertical so move to that loop
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, shiftprvloop	# if $t9 == $t3 then shiftprvloop

		# If $t9 == 0 then the pipe is horizontal so move to that loop
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, shiftprhloop	# if $t9 == $t3 then shiftprhloop

		# If we don't hit one of these then something went wrong and it's best to change anything
		j		ploop				# jump to ploop


		shiftprvloop:

			# If we're moving past the end of the board we don't want to move
      	  	addi    $t7, $zero, 8       # $t7 = $zero + 8
       		beq     $t0, $t7, droppv    # if $t0 == $t7 then droppv

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, droppv	# if $v0 != $zero then droppv

			# Subtract 1 from y to move up
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 4 times we've accounted for each square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 4		# $t7 = $zero + 1
			beq		$t8, $t7, moveprv	# if $t8 == $t1 then moveprv

			# If we're at the top row and we are here then we are free to move
			beq		$t1, $zero, moveprv	# if $t1 == $zero then moveprv

			# Jump back to the top of our loop
			j		shiftprvloop			# jump to shiftprloop

		shiftprhloop:

			# If we're moving past the end of the board we don't want to move
      	  	addi    $t7, $zero, 8       # $t7 = $zero + 8
       		beq     $t0, $t7, dropph    # if $t0 == $t7 then dropph

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, dropph	# if $t0 != $zero then dropph

			# Store a 1 in a register since we'll need it
			addi	$t3, $zero, 1		# $t3 = $zero + 1

			# If the spot is free we want to shift there
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We want to store the new value of PX
			sw		$t0, PX		#

			# We now want to subtract to the beginning of the pipe
			sub		$t4, $t0, $t3		# $t4 = $t4 - $t3
			sub		$t4, $t4, $t3		# $t4 = $t4- $t3
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

			# Set this piece to 0 since we moved past the space
			add		$a0, $t4, $zero		# $a0 = $t4 + $zero
			add		$a1, $t1, $zero		# $a1 = $t4 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We're done so let's drop our piece
			j		dropph				# jump to ploop


	shiftpl:

		# Load our X and Y values
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We subtract 1 from our PX value for testing purposes
		addi	$t6, $zero, 1		# $t6 = $zero + 1
		sub		$t0, $t0, $t6		# $t0 = $t0 - $t6

		# If $t9 == 1 then the pipe is vertical so move to that loop
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$t9, $t3, shiftplvloop	# if $t9 == $t3 then shiftprvloop

		# If $t9 == 0 then the pipe is horizontal so move to that loop
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$t9, $t3, shiftplhloop	# if $t9 == $t3 then shiftprhloop

		# If we don't hit one of these then something went wrong and it's best to change anything
		j		droppv				# jump to droppv

		shiftplvloop:

			# If we're in the first column we don't even want to bother shifting
			blt		$t0, $zero, droppv	# if $t0 == $zero then droppv

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# We want to get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, droppv	# if $v0 != $zero then droppv

			# If PY is 0 then we are at the top so we can move
			beq		$t1, $zero, moveplv	# if $t1 == $zero then moveprv

			# Subtract 1 from y to move up
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 4 times we've accounted for each square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 4		# $t7 = $zero + 1
			beq		$t8, $t7, moveplv		# if $t8 == $t1 then moveprv

			# Jump back to the top of our loop
			j		shiftplvloop			# jump to shiftprloop

		shiftplhloop:

			# We will need this later
			addi	$t3, $zero, 1			# $t3 = $zero + 1

			# Since we subtracted one at the top, I'm in position
			# 3 in relation to the pivot. I need to get to 0
			# We stop to check if we're in the first column or not
			sub		$t4, $t0, $t3		# $t4 = $t0 - $t3
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

			# If we're in the first column we don't even want to bother shifting
			beq		$t4, $zero, dropph	# if $t0 == $zero then droppv
			sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

			# Get the value stored at PX,PY
			add		$a0, $t4, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y back
			add		$t4, $a0, $zero		# $t4 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift
			bne		$v0, $zero, dropph	# if $t0 != $zero then dropph

			# If the spot is free we want to shift there
			add		$a0, $t4, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We want our X and Y back
			add		$t4, $a0, $zero		# $t4 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We want to shift our X pivot to the left one
			lw		$t0, PX		#
			addi	$t2, $zero, 1			# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2
			sw		$t0, PX		#

			# Since we subtracted once before coming here
			# We want to add 1 to get back to the space to set 0
			addi	$t0, $t0, 1			# $t0 = $t0 + 1

			# Set this piece to 0 since we moved past the space
			add		$a0, $t0, $zero		# $a0 = $t4 + $zero
			add		$a1, $t1, $zero		# $a1 = $t4 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We're done so let's drop the piece
			j		dropph				# jump to dropph

	rotatep:

		# Determine which state the piece is currently in, then rotate
		addi	$t0, $zero, 1			# $t0 = $zero + 1
		beq		$t9, $t0, rotatepvh	# if $t9 == $t0 then rotatepvh

		addi	$t0, $zero, 2			# $t0 = $zero + 2
		beq		$t9, $t0, rotatephv	# if $t9 == $t0 then rotatephv

		rotatepvh:

			# Load X and Y
			lw		$t0, PX		#
			lw		$t1, PY		#

			# If the whole pipe isn't being shown, we don't allow rotations
			addi	$t2, $zero, 4		# $t2 = $zero + 4
			blt		$t1, $t2, droppv	# if $t1 < $t2 then droopv

			# If we're too far over, we won't rotate
			addi	$t2, $zero, 5		# $t2 = $zero + 6
			bgt		$t0, $t2, droppv	# if $t0 > $t2 then droppv

			# If we're too close to the left edge, we drop
			beq		$t0, $zero, droppv	# if $t0 == $zero then droppv

			# Subtract 2 from Y to get to our pivot point
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# We subtract 1 from X to check if the space is clear
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# We get the value at this position
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# if this space isn't clear, we don't want to rotate
			bne		$v0, $zero, droppv	# if $v0 != $zero then dropv

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add two spaces to X to check that space
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# We get the value at this position
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# if this space isn't clear, we don't want to rotate
			bne		$v0, $zero, droppv	# if $v0 != $zero then dropv

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 and check the final space
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# We get the value at this position
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# if this space isn't clear, we don't want to rotate
			bne		$v0, $zero, droppv	# if $v0 != $zero then dropv

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If we make it this far, we are free to rotate

			# We reload our PX and PY values
			lw		$t0, PX		#
			lw		$t1, PY		#

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Decreent from Y to move up
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We decrement Y by 2 to get the top square
			addi	$t2, $zero, 2			# $t2 = $zero + 2
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 to Y and Subtract 1 from X to get to the far left position
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t1, $t1, $t2		# $t1 = $t1 + $t2
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1			# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 2 to X to get to the right position
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 to X to move to the far right position
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t0, $t0, $t2		# $t0 = $t0 + $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# We want to store the new X and Y value
			sw		$t0, PX		#
			sw		$t1, PY		#

			# Set our rotation register to indicate we are horizontal
			addi	$t9, $zero, 2		# $t9 = $zero + 2

			j		dropph				# jump to dropph


		rotatephv:

			# Load X and Y
			lw		$t0, PX		#
			lw		$t1, PY		#

			# If Y is 0 then we don't allow rotation
			beq		$t1, $zero, dropph	# if $t1 == $zero then dropph

			# Subtract 2 from X to get the right pivot position
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Subtract 1 from Y to shift up a block
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Get the value stored here
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this spot is not free do not allow a rotation
			bne		$v0, $zero, dropph	# if $v0 != $zero then dropph

			# Add 2 to Y to get the next position to check
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			add		$t1, $t1, $t2		# $t1 = $t1 + $t2

			# Get the value stored here
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this spot is not free do not allow a rotation
			bne		$v0, $zero, dropph	# if $v0 != $zero then dropph

			# Add 1 to Y to get the last spot to check
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			add		$t1, $t1, $t2		# $t1 = $t1 + $t2

			# Get the value stored here
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this spot is not free do not allow a rotation
			bne		$v0, $zero, dropph	# if $v0 != $zero then dropph

			# If we make it to this point then we are free to rotate

			# Load our original X and Y values
			lw		$t0, PX		#
			lw		$t1, PY		#

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 1 from X to get the square
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Subtract 2 from X to get the far left square
			addi	$t2, $zero, 2		# $t2 = $zero + 2
			sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

			# Set this value to 0
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add one 1 X to get back to pivot point and subtract 1 from Y to get the top square
			addi	$t0, $t0, 1			# $t0 = $t0 + 1
			addi	$t2, $zero, 1		# $t2 = $zero + 1
			sub		$t1, $t1, $t2		# $t1 = $t1 - $t2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 2 to Y to drop it below the pivot
			addi	$t1, $t1, 2			# $t1 = $t1 + 2

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Add 1 to Y to get to the last square
			addi	$t1, $t1, 1			# $t1 = $t1 + 1

			# Set this value to 1
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			addi	$a2, $zero, 1		# $a2 = $zero + 1
			jal		SETXY				# jump to SETXY and save position to $ra

			# Get our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Store our new pivot
			sw		$t0, PX		#
			sw		$t1, PY		#

			# Set out rotation value to 1
			addi	$t9, $zero, 1			# $t9 = $zero + 1

			# Jump back to ploop
			j		ploop				# jump to ploop

	droppv:

		# Load our PX and PY value
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We add 1 to look at the square below ours
		addi	$t1, $t1, 1		# $t2 = $zero + 1

        # Check to make sure we haven't gone to the end of the board
        addi    $t4, $zero, 16           # $t4 = $zero + 16
        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

		# Check what value is stored at this location
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

        # If the space isn't empty, we're done so check the board
        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

        # We add 1 to PY since we're dropping some
        addi    $t1, $t1, 1            # $t1 = $t1 + 1

        # If we're not done, we store our new pointer
        sw      $t0, PX        #
        sw      $t1, PY        #

		# Set our new value to 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		addi	$a2, $zero, 1		# $a2 = $t2 + 1
		jal		SETXY				# jump to SETXY and save position to $ra

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

		# Keep subtracting one to move up the piece unless we hit the top of the board
		addi	$t2, $zero, 1			# $t2 = $zero + 1

		sub		$t4, $t1, $t2		# $t4 = $t1 - $t2
		beq		$t4, $zero, ploop	# if $t4 == $zero then ploop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2
		beq		$t4, $zero, ploop	# if $t4 == $zero then ploop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2
		beq		$t4, $zero, ploop	# if $t4 == $zero then ploop

		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2

		# Set this value to 0 since we dropped below it
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t4, $zero		# $a1 = $t4 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

        beq     $t4, $zero, ploop   # if $t4 == $zero then ploop

        # After we drop, we print
        jal     PRINTBOARD       # jump to PRINTBOARD and save position to $ra

		# If we make it this far then we are mid drop so we want more input
		j		ploop				# jump to ploop

	dropph:

		# Load our PX and PY values
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Add 1 to Y to check below us
		addi	$t1, $t1, 1			# $t1 = $t1 + 1

		# If we're at the end of the board, we're done
		addi	$t2, $zero, 16			# $t2 = $zero + 16
		beq		$t1, $t2, CHECKBOARD	# if $t1 == $t2 then CHECKBOARD

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $read

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# Subtract 1 from X to check the next space
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# Subtract 1 from X to check the next space
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# Subtract 1 from X to check the next space
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# Check the value of the board at this position
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

		# Get our X and Y values back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a + $t2

		# If there is a piece here we don't move and check the board
		bne		$v0, $zero, CHECKBOARD	# if $v0 != $zero then CHECKBOARD

		# If we're at this point then we want to make the move

		# We load the original X and Y
		lw		$t0, PX		#
		lw		$t1, PY		#

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# Subtract 1 from X to move to the next positon
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# Subtract 1 from X to move to the next positon
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# Subtract 1 from X to move to the next positon
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		sub		$t0, $t0, $t2		# $t0 = $t0 - $t2

		# We want to set these top four results to 0
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Get our X and Y back
		add		$t0, $a0, $zero		# $t0 = $a0 + $zero
		add		$t1, $a1, $zero		# $t1 = $a1 + $zero

		# We add 1 to Y to move to the next row
		addi	$t1, $t1, 1			# $t1 = $t1 + 1

		# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# Add 1 to X to set the next spot
	 	addi	$t0, $t0, 1		# $t0 = $zero + 1

	 	# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# Add 1 to X to set the next spot
	 	addi	$t0, $t0, 1		# $t0 = $zero + 1

	 	# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# Add 1 to X to set the next spot
	 	addi	$t0, $t0, 1		# $t0 = $zero + 1

	 	# We want to set this value to 1
		addi	$t2, $zero, 1		# $t2 = $zero + 1
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		add		$a2, $t2, $zero		# $a2 = $t2 + $zero
	 	jal		SETXY				# jump to SETXY and save position to $ra

	 	# Get X and Y back
	 	add		$t0, $a0, $zero		# $t0 = $a0 + $zero
	 	add		$t1, $a1, $zero		# $t1 = $a1 + $zero

	 	# We want to store our new pointers
	 	sw		$t0, PX		#
	 	sw		$t1, PY		#

	 	jal		PRINTBOARD				# jump to PRINTBOARD and save position to $ra


	 	# Since we haven't hit anything we jump to ploop and wait
	 	j		ploop				# jump to ploop


	moveprv:

		# Load the original PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Shift our x value to the right once
		addi	$t2, $t0, 1			# $t0 = $t0 + 1
		sw		$t2, PX		#

		# Initialize some counters
		addi	$t6, $zero, 4			# $t6 = $zero + 4
		addi	$t5, $zero, 1			# $t5 = $zero + 1

		moveprvloop:

			# Load 1 into a register since that's what we use for this piece
			addi	$t3, $zero, 1			# $t3 = $zero + 1

			# Reload PX
			lw		$t2, PX		#

			# Set the value at the current position
			add		$a0, $zero, $t2		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t3		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# Move our Y value back since it certainly moved
			add		$t1, $a1, $zero		# $t1 = $a0 + $zero

			# Reload X and move it to the previous spot
			lw		$t0, PX		#
			addi	$t3, $zero, 1		# $t3 = $zero + 1
			sub		$t0, $t0, $t3		# $t0 = $t0 - $t3

			# We want to set the spot we moved from to zero
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# Reset X and Y after the function call
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, droppv	# if $t1 == $zero then droppv
			beq		$t5, $t6, droppv	# if $t5 == $t6 then droppv

			# We need to increase our counter and move our y-value
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4

			j		moveprvloop			# jump to moveprvloop

	moveplv:

		# Load the original PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

		# Shift our x value to the left once
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		sub		$t2, $t0, $t3		# $t2t = $t0 - $t3
		sw		$t2, PX		#

		# Initialize some counters
		addi	$t6, $zero, 4			# $t6 = $zero + 4
		addi	$t5, $zero, 1			# $t5 = $zero + 1

		moveplvloop:

			# Load 1 into a register since that's what we use for this piece
			addi	$t3, $zero, 1			# $t3 = $zero + 1

			# Set the value at the current position
			add		$a0, $zero, $t2		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t3		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# Move our Y value back
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero

			# Reload X and move it to the previous spot
			lw		$t0, PX		#
			addi	$t0, $t0, 1		# $t0 = $t0 + 1

			# We want to set the spot we moved from to zero
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We need to set our X and Y back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, droppv	# if $t1 == $zero then droppv
			beq		$t5, $t6, droppv	# if $t5 == $t6 then droppv

			# We need to increase our counter and move our y-value
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4

			j		moveplvloop			# jump to moveprvloop

.globl CREATET
CREATET:

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well
	addi	$t0, $zero, 3			# $t0 = X + 3
	addi	$t1, $zero, 0			# $t1 = $zero + 0

    # Store the value for safe keeping
    sw      $t0, PX        #
    sw      $t1, PY        #

	# Store the first position of the board
	addi	$t2, $zero, 1		# $t1 = $zero + 1
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	add		$a2, $zero, $t2		# $a2 = $zero + $t2
	jal		SETXY				# jump to SETXY and save position to $ra

	# $t9 holds the rotation state.
	addi	$t9, $zero, 1			# $t7 = $zero + 1

    # Start the piece loop
    j        tloop                # jump to ploop

    tloop:
    	# We want to print our board back to Python
        jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input
		li		$v0, 5		# $v0 = 5
		syscall				# execute

		# Load PX and PY
		lw		$t0, PX		#
		lw		$t1, PY		#

    	# Check the response from Python and jump to the corresponding branch
    	addi	$t2, $zero, 1		# $t2 = $zero + 1
    	beq		$v0, $t2, shifttl	# if $v0 == $t2 then shifttl

    	addi	$t2, $zero, 2		# $t2 = $zero + 2
    	beq		$v0, $t2, shifttr	# if $v0 == $t2 then shifttr

    	addi	$t2, $zero, 3		# $t2 = $zero + 3
    	beq		$v0, $t2, rotatet	# if $v0 == $t2 then rotatet

    	# If we get this far then we just want to drop our piece
    	j		dropt				# jump to dropt

    shifttl:

    	# Determine which rotation state of the board and move to the correct shift loop
    	addi	$t0, $zero, 1			# $t0 = $zero + 1
    	beq		$t0, $t9, shifttlone	# if $t0 == $t9 then shifttlone

    	addi	$t0, $zero, 2			# $t0 = $zero + 2
    	beq		$t0, $t9, shifttltwo	# if $t0 == $t9 then shifttltwo

    	addi	$t0, $zero, 3			# $t0 = $zero + 3
    	beq		$t0, $t9, shifttlthree	# if $t0 == $t9 then shifttlthree

    	addi	$t0, $zero, 4			# $t0 = $zero + 4
    	beq		$t0, $t9, shifttlfour	# if $t0 == $t9 then shifttlfour

    	j		dropt				# jump to dropt

    	shifttlone:
    		# Load our X and Y values
    		lw		$t0, PX		#
    		lw		$t1, PY		#


    	shifttltwo:
    	shifttlthree:
    	shifttlfour:

    shifttr:

   	dropt:

   	rotatet:

.globl CREATEL
CREATEL:
        # We're picking our middle position to be 3 so let's move X there
        # We also want to make sure we're starting at our top row as well
        addi	$t0, $zero, 3			# $t0 = X + 3
        addi	$t1, $zero, 0			# $t1 = $zero + 0

        # Store the value for safe keeping
        sw      $t0, PX        #
        sw      $t1, PY        #

        # Store the first position of the board
        addi	$t2, $zero, 5		# $t1 = $zero + 1
        add		$a0, $zero, $t0		# $a0 = $zero + $t0
        add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
        add		$a2, $zero, $t2		# $a2 = $zero + $t2
        jal		SETXY				# jump to SETXY and save position to $ra

        lw      $t0, PX        #
        lw      $t1, PY        #

        addi		$a0, $t0, 1		# $a0 = $zero + $t0
        add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
        add		$a2, $zero, $t2		# $a2 = $zero + $t2
        jal		SETXY				# jump to SETXY and save position to $ra

        # $t9 holds the rotation state. 1 for vertical, 2 for horizontal
        ##  for this piece (the L), we'll need two more values:
        ## 3 for upside down, and 4 for horizontal in the opposite directon
        ## I'll probably implement this as a clock face moving widdershins,
        ## where 1 is 6, 2 is 3, 3 is 12, and 4 is 9.
        ##
        ## obviously we start in a vertical state
        addi	$t9, $zero, 1			# $t7 = $zero + 1

        ## start our loop for the L piece
        j lloop

lloop:
        ## print out our board
        jal PRINTBOARD

        # Prompt for user input from Python
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

                        # Make MIPS wait for integer input
        li		$v0, 5		# $v0 = 5
        syscall				# execute

        # Load PX and PY
        lw		$t0, PX		#
        lw		$t1, PY		#

        # A counter for moving pieces
        addi	$t8, $zero, 1			# $t8 = $zero + 1

        # If Python sends us a 2 we want to shift our piece left
        addi	$t3, $zero, 1			# $t3 = $zero + 2
        beq	$v0, $t3, shiftll	# if $v0 == $t3 then shiftll

        # If Python sends us a 1 we want to shift our piece right
        addi	$t3, $zero, 2			# $t3 = $zero + 1
        beq	$v0, $t3, shiftlr	# if $v0 == $t3 then shiftlr

        # If Python sends us a 3 then we want to rotate the piece
        addi	$t3, $zero, 3			# $t3 = $zero + 3
        beq	$v0, $t3, rotatel	# if $v0 == $t3 then target

        # If our piece is in position 1 then drop vertical
        addi	$t3, $zero, 1			# $t3 = $zero + 1
        beq	$t9, $t3, droplv	# if $t9 == $t3 then droplv

        # If our piece is in position 2 then drop horizontal
        addi	$t3, $zero, 2			# $t3 = $zero + 2
        beq	$t9, $t3, droplh	# if $t9 == $t3 then droplh

        # If we get here something is wrong so we wait for another input
        j		lloop				# jump to lloop

shiftlr:

        # If we're moving past the end of the board we don't want to move
        addi    $t7, $zero, 7       # $t7 = $zero + 8
        beq     $t0, $t7, droplv    # if $t0 == $t7 then droplv

                # We add one to our PX-value for testing purposes
                addi	$t0, $t0, 1			# $t0 = $t0 + 1

                # We need a counter initialized for looping purposes
                addi	$t8, $zero, 1			# $t8 = $zero + 1

                # If $t9 == 1 then the pipe is vertical so move to that loop
                addi	$t3, $zero, 1			# $t3 = $zero + 1
                beq		$t9, $t3, shiftlrvloop	# if $t9 == $t3 then shiftlrvloop

                # If $t9 == 0 then the pipe is horizontal so move to that loop
                addi	$t3, $zero, 2			# $t3 = $zero + 2
                beq		$t9, $t3, shiftlrhloop	# if $t9 == $t3 then shiftlrhloop

                # If we don't hit one of these then something went wrong and it's best to change anything
                j		lloop				# jump to lloop


                shiftlrvloop:

                        # Get the value stored at PX,PY
                        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        jal		GETARGXY			# jump to GETARGXY and save position to $ra

                        # Get our values of x and y back
                        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
                        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # If this position is not free, then we don't want to shift
                        bne		$v0, $zero, droplv	# if $v0 != $zero then droplv

                        # Subtract 1 from y to move up
                        addi	$t7, $zero, 1		# $t7 = $zero + 1
                        sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

                        # If we've run this loop 4 times we've accounted for each square
                        addi	$t8, $t8, 1			# $8 = $t8 + 1
                        addi	$t7, $zero, 4		# $t7 = $zero + 1
                        beq		$t8, $t7, movelrv	# if $t8 == $t1 then movelrv

                        # If we're at the top row and we are here then we are free to move
                        beq		$t1, $zero, movelrv	# if $t1 == $zero then movelrv

                        # Jump back to the top of our loop
                        j		shiftlrvloop			# jump to shiftlrloop

                shiftlrhloop:

                        # Get the value stored at PX,PY
                        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        jal		GETARGXY			# jump to GETARGXY and save position to $ra

                        # If this position is not free, then we don't want to shift
                        bne		$t0, $zero, droplh	# if $t0 != $zero then droplh

                        # Store a 1 in a register since we'll need it
                        addi	$t3, $zero, 5			# $t3 = $zero + 1

                        # If the spot is free we want to shift there
                        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        add		$a2, $t3, $zero		# $a2 = $t3 + $zero
                        jal		SETXY				# jump to SETXY and save position to $ra

                        # We want to store the new value of PX
                        sw		$t0, PX		#

                        # We now want to subtract to the beginning of the pipe
                        sub		$t4, $t0, $t3		# $t4 = $t4 - $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4- $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4 - $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4 - $t3

                        # Set this piece to 0 since we moved past the space
                        add		$a0, $t4, $zero		# $a0 = $t4 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t4 + $zero
                        add		$a2, $zero, $zero	# $a2 = $zero + $zero

                        # We're done so let's drop our piece
                        j		droplh				# jump to lloop


        shiftll:

                # If we're in the first column we don't even want to bother shifting
                beq		$t0, $zero, droplv	# if $t0 == $zero then droplv

                # We subtract 1 from our PX value for testing purposes
                addi	$t6, $zero, 1		# $t6 = $zero + 1
                sub		$t0, $t0, $t6		# $t0 = $t0 - $t6

                # If $t9 == 1 then the pipe is vertical so move to that loop
                addi	$t3, $zero, 1			# $t3 = $zero + 1
                beq		$t9, $t3, shiftllvloop	# if $t9 == $t3 then shiftlrvloop

                # If $t9 == 0 then the pipe is horizontal so move to that loop
                addi	$t3, $zero, 2			# $t3 = $zero + 2
                beq		$t9, $t3, shiftllhloop	# if $t9 == $t3 then shiftlrhloop

                # If we don't hit one of these then something went wrong and it's best to change anything
                j		droplv				# jump to droplv

                shiftllvloop:

                        # Get the value stored at PX,PY
                        add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        jal		GETARGXY			# jump to GETARGXY and save position to $ra

                        # We want to get our X and Y values back
                        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
                        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # If this position is not free, then we don't want to shift
                        bne		$v0, $zero, droplv	# if $v0 != $zero then droplv

                        # If PY is 0 then we are at the top so we can move
                        beq		$t1, $zero, movellv	# if $t1 == $zero then movelrv

                        # Subtract 1 from y to move up
                        addi	$t7, $zero, 1		# $t7 = $zero + 1
                        sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

                        # If we've run this loop 4 times we've accounted for each square
                        addi	$t8, $t8, 1			# $8 = $t8 + 1
                        addi	$t7, $zero, 4		# $t7 = $zero + 1
                        beq		$t8, $t7, movellv		# if $t8 == $t1 then movelrv

                        # Jump back to the top of our loop
                        j		shiftllvloop			# jump to shiftlrloop

                shiftllhloop:

                        # We will need this later
                        addi	$t3, $zero, 5			# $t3 = $zero + 1

                        # Since we subtracted one at the top, I'm in position
                        # 3 in relation to the pivot. I need to get to 0
                        sub		$t4, $t0, $t3		# $t4 = $t0 - $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4 - $t3
                        sub		$t4, $t4, $t3		# $t4 = $t4 - $t3


                        # Get the value stored at PX,PY
                        add		$a0, $t4, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        jal		GETARGXY			# jump to GETARGXY and save position to $ra

                        # If this position is not free, then we don't want to shift
                        bne		$t0, $zero, droplh	# if $t0 != $zero then droplh

                        # If the spot is free we want to shift there
                        add		$a0, $t4, $zero		# $a0 = $t0 + $zero
                        add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                        add		$a2, $t3, $zero		# $a2 = $t3 + $zero
                        jal		SETXY				# jump to SETXY and save position to $ra

                        # We want to store this value in PX since it represents the new pivot
                        sw		$t0, PX		#

                        # Since we subtracted once before coming here
                        # We want to add 1 to get back to the space to set 0
                        add		$t0, $t0, $t3		# $t0 = $t0 + $t3

                        # Set this piece to 0 since we moved past the space
                        add		$a0, $t0, $zero		# $a0 = $t4 + $zero
                        add		$a1, $t4, $zero		# $a1 = $t4 + $zero
                        add		$a2, $zero, $zero	# $a2 = $zero + $zero

                        # We're done so let's drop the piece
                        j		droplh				# jump to droplh

        rotatel:

        droplv:

                # Load our PX and PY value
                lw		$t0, PX		#
                lw		$t1, PY		#

                # We add 1 to look at the square below ours
                addi	$t1, $t1, 1		# $t2 = $zero + 1

                # Check to make sure we haven't gone to the end of the board
                addi    $t4, $zero, 16           # $t4 = $zero + 16
                beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD

                # Check what value is stored at this location
                add		$a0, $t0, $zero		# $a0 = $t0 + $zero
                add		$a1, $t1, $zero		# $a1 = $t1 + $zero
                jal		GETARGXY			# jump to GETARGXY and save position to $ra

        # If the space isn't empty, we're done so check the board
        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

        # We add 1 to PY since we're dropping some
        addi    $t1, $t1, 1            # $t1 = $t1 + 1

        # If we're not done, we store our new pointer
        sw      $t0, PX        #
        sw      $t1, PY        #

                # Set our new value to 1
        add	$a0, $t0, $zero		# $a0 = $t0 + $zero
        add	$a1, $t1, $zero		# $a1 = $t1 + $zero
        addi	$a2, $zero, 5		# $a2 = $t2 + 1
        jal	SETXY			# jump to SETXY and save position to $ra

        lw      $t0, PX     #
        lw      $t1, PY     #

        ##  now let's take care of the bottom of the L
        addi    $a0, $t0, 1
        add	$a1, $t1, $zero		# $a1 = $t1 + $zero
        addi	$a2, $zero, 5		# $a2 = $t2 + 1
        jal	SETXY			# jump to SETXY and save position to $ra

        lw      $t0, PX     #
        lw      $t1, PY     #

        ## time to erase our previous bottom of the L
        addi    $a0, $t0, 1
        addi	$a1, $t1, -1		# $a1 = $t1 + $zero
        addi	$a2, $zero, 0		# $a2 = $t2 + 1
        jal	SETXY			# jump to SETXY and save position to $ra


        # Load our PX and PY value
        lw      $t0, PX     #
        lw      $t1, PY     #

        # Keep subtracting one to move up the piece unless we hit the top of the board
        addi	$t2, $zero, 1			# $t2 = $zero + 1

        sub	$t4, $t1, $t2		# $t4 = $t1 - $t2
        beq	$t4, $zero, lloop	# if $t4 == $zero then lloop

        sub	$t4, $t4, $t2		# $t4 = $t4 - $t2
        beq	$t4, $zero, lloop	# if $t4 == $zero then lloop

        sub	$t4, $t4, $t2		# $t4 = $t4 - $t2
        beq	$t4, $zero, lloop	# if $t4 == $zero then lloop

        sub	$t4, $t4, $t2		# $t4 = $t4 - $t2

        # Set this value to 0 since we dropped below it
        add     $a0, $t0, $zero		# $a0 = $t0 + $zero
        add	$a1, $t4, $zero		# $a1 = $t4 + $zero
        add	$a2, $zero, $zero	# $a2 = $zero + $zero
        jal	SETXY				# jump to SETXY and save position to $ra

        beq     $t4, $zero, lloop   # if $t4 == $zero then lloop

        # After we drop, we print
        jal     PRINTBOARD       # jump to PRINTBOARD and save position to $ra

                # If we make it this far then we are mid drop so we want more input
                j		lloop				# jump to ploop

        droplh:

        movelrv:

                # Load the original PX and PY
                lw	$t0, PX		#
                lw	$t1, PY		#

                # Shift our x value to the right once
                addi	$t2, $t0, 1			# $t0 = $t0 + 1
                sw	$t2, PX		#

                # Initialize some counters
                addi	$t6, $zero, 4			# $t6 = $zero + 4
                addi	$t5, $zero, 1			# $t5 = $zero + 1

                movelrvloop:

                # Load 1 into a register since that's what we use for this piece
                addi	$t3, $zero, 5			# $t3 = $zero + 1

                # Reload PX
                lw	$t2, PX		#

                # Set the value at the current position
                add	$a0, $zero, $t2		# $a0 = $zero + $t2
                add	$a1, $zero, $t1		# $a1 = $zero + $t1
                add	$a2, $zero, $t3		# $a2 = $zero + $t3
                jal	SETXY				# jump to SETXY

                # Move our Y value back since it certainly moved
                add	$t1, $a1, $zero		# $t1 = $a0 + $zero

                # Reload X and move it to the previous spot
                lw	$t0, PX		#
                addi	$t3, $zero, 1		# $t3 = $zero + 1
                sub	$t0, $t0, $t3		# $t0 = $t0 - $t3

                # We want to set the spot we moved from to zero
                add	$a0, $zero, $t0		# $a0 = $zero + $t0
                add	$a1, $zero, $t1		# $a1 = $zero + $t1
                add	$a2, $zero, $zero	# $a2 = $zero + $zero
                jal	SETXY				# jump to SETXY and save position to $ra

                # Reset X and Y after the function call
                add	$t0, $a0, $zero		# $t0 = $a0 + $zero
                add	$t1, $a1, $zero		# $t1 = $a1 + $zero

                # If we're at the top of the board or we're done shifting pieces we wait for the next input
                beq	$t1, $zero, droplv	# if $t1 == $zero then droplv
                beq	$t5, $t6, droplv	# if $t5 == $t6 then droplv

                # We need to increase our counter and move our y-value
                addi	$t4, $zero, 1		# $t4 = $zero + 1
                add	$t5, $t5, $t4		# $t5 = $t5 + $t4
                sub	$t1, $t1, $t4		# $t1 = $t1 - $t4

                j	movelrvloop			# jump to movelrvloop

        movellv:

                # Load the original PX and PY
                lw	$t0, PX		#
                lw	$t1, PY		#

                # Shift our x value to the left once
                addi	$t3, $zero, 1			# $t3 = $zero + 1
                sub	$t2, $t0, $t3		# $t2t = $t0 - $t3
                sw	$t2, PX		#

                # Initialize some counters
                addi	$t6, $zero, 4			# $t6 = $zero + 4
                addi	$t5, $zero, 1			# $t5 = $zero + 1

                movellvloop:

                        # Load 1 into a register since that's what we use for this piece
                        addi	$t3, $zero, 5			# $t3 = $zero + 1

                        # Set the value at the current position
                        add		$a0, $zero, $t2		# $a0 = $zero + $t2
                        add		$a1, $zero, $t1		# $a1 = $zero + $t1
                        add		$a2, $zero, $t3		# $a2 = $zero + $t3
                        jal		SETXY				# jump to SETXY

                        # Move our Y value back
                        add	$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # Reload X and move it to the previous spot
                        lw		$t0, PX		#
                        addi	$t0, $t0, 1		# $t0 = $t0 + 1

                        # We want to set the spot we moved from to zero
                        add		$a0, $zero, $t0		# $a0 = $zero + $t0
                        add		$a1, $zero, $t1		# $a1 = $zero + $t1
                        add		$a2, $zero, $zero	# $a2 = $zero + $zero
                        jal		SETXY				# jump to SETXY and save position to $ra

                        # We need to set our X and Y back
                        add		$t0, $a0, $zero		# $t0 = $a0 + $zero
                        add		$t1, $a1, $zero		# $t1 = $a1 + $zero

                        # If we're at the top of the board or we're done shifting pieces we wait for the next input
                        beq		$t1, $zero, droplv	# if $t1 == $zero then droplv
                        beq		$t5, $t6, droplv	# if $t5 == $t6 then droplv

                        # We need to increase our counter and move our y-value
                        addi	$t4, $zero, 1		# $t4 = $zero + 1
                        add		$t5, $t5, $t4		# $t5 = $t5 + $t4
                        sub		$t1, $t1, $t4		# $t1 = $t1 - $t4

                        j		movellvloop			# jump to movelrvloop

.globl CREATES
CREATES:

	# Left block is 3,so let's move X there
	# We also want to make sure we're starting at our top row as well 
	addi	$t0, $zero, 3			# $t0 = X + 3 
	addi	$t1, $zero, 0			# $t1 = $zero + 0

    # Store the value for safe keeping
    sw      $t0, PX        # 
    sw      $t1, PY        # 
    
	# Store the left side on the board, value = 2 for SQUARE
	addi	$t2, $zero, 2		# $t2 = $zero + 2
	add		$a0, $zero, $t0		# $a0 = $zero + $t0
	add		$a1, $zero, $t1		# $a1 = $tzero+ $t1
	add		$a2, $zero, $t2		# $a2 = $zero + $t2
	jal		SETXY				# jump to SETXY and save position to $ra

	# Right block is 4, X now starts on bottom right
	addi	$t0, $zero, 4
	addi 	$t1, $zero, 0

	# Store the value
	sw		$t0, PX
	sw		$t1, PY

	# Store right side on board
	add		$t2, $zero, 2
	add		$a0, $zero, $t0
	add		$a1, $zero, $t1
	add		$a2, $zero, $t2
	jal		SETXY

    # Start the piece loop 
    j        sloop                # jump to sloop
    

	sloop:

        # We want to print our board back to Python 
        jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

        # Prompt for user input from Python 
        li        $a0, 1        # $a0 = 1
        li        $v0, 1        # $v0 = 1
        syscall

        # Print a new line
        li      $v0, 4      # system call #4 - print string
        la      $a0, newline    # $a0 = $zero + 15
        syscall             # execute

		# Make MIPS wait for integer input 
		li		$v0, 5		# $v0 = 5	
		syscall				# execute

		# Load PX and PY
		lw		$t0, PX		# 
		lw		$t1, PY		# 

		# A counter for moving pieces 
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 1 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$v0, $t3, shiftsl	# if $v0 == $t3 then shiftsl

		# If Python sends us a 2 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq		$v0, $t3, shiftsr	# if $v0 == $t3 then shiftsr

		# Otherwise, we drop
		j		drops
	
	shiftsr:

        # If we're moving past the end of the board we don't want to move
        addi    $t7, $zero, 7       # $t7 = $zero + 8
        beq     $t0, $t7, drops    # if $t0 == $t7 then drops

		# We add one to our PX-value for testing purposes 
		addi	$t0, $t0, 1			# $t0 = $t0 + 1

		# We need a counter initialized for looping purposes 
		addi	$t8, $zero, 1			# $t8 = $zero + 1
		
		#need to do shift, goto shiftsrloop
		j		shiftsrloop
		
		shiftsrloop:

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back 
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If this position is not free, then we don't want to shift 
			bne		$v0, $zero, drops	# if $v0 != $zero then drops
			
			# Subtract 1 from y to move up 
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 2 times we've accounted for each square on the right
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 2		# $t7 = $zero + 2
			beq		$t8, $t7, movesr	# if $t8 == $t1 then movesr

			# If we're at the top row and we are here then we are free to move
			beq		$t1, $zero, movesr	# if $t1 == $zero then movesr
									
			# Jump back to the top of our loop 
			j		shiftsrloop			# jump to shiftsrloop

	shiftsl:
		#reload x and y
		lw	$t0, PX
		lw	$t1, PY

		#add -1 to x to check left side of square
		addi	$t0, $t0, -1	

		# If we're in the first column we don't even want to bother shifting 
		beq		$t0, $zero, drops	# if $t0 == $zero then dropsv

		# We subtract 1 from our PX value for testing purposes 
		addi	$t6, $zero, 1		# $t6 = $zero + 1
		sub		$t0, $t0, $t6		# $t0 = $t0 - $t6
		
		#now do the shift
		j		shiftslloop
	
		shiftslloop:

			# Get the value stored at PX,PY
			add		$a0, $t0, $zero		# $a0 = $t0 + $zero
			add		$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal		GETARGXY			# jump to GETARGXY and save position to $ra

			# We want to get our X and Y values back
			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
			add		$t1, $a1, $zero		# $t1 = $a1 + $zero

			# If this position is not free, then we don't want to shift 
			bne		$v0, $zero, drops	# if $v0 != $zero then drops

			# If PY is 0 then we are at the top so we can move
			beq		$t1, $zero, movesl	# if $t1 == $zero then movesl
			
			# Subtract 1 from y to move up 
			addi	$t7, $zero, 1		# $t7 = $zero + 1
			sub		$t1, $t1, $t7		# $t1 = $t1 - $t7

			# If we've run this loop 2 times we've accounted for each block in the square
			addi	$t8, $t8, 1			# $8 = $t8 + 1
			addi	$t7, $zero, 2		# $t7 = $zero + 2
			beq		$t8, $t7, movesl		# if $t8 == $t7 then movesl

			# Jump back to the top of our loop 
			j		shiftslloop			# jump to shiftsrloop

	drops:       
        
		# Load our PX and PY value 
		lw		$t0, PX		# 
		lw		$t1, PY		# 

		# We add 1 to Y to look at the square below ours
		addi	$t1, $t1, 1		# $t1 = $t1 + 1

        # Check to make sure we haven't gone to the end of the board 
        addi    $t4, $zero, 16           # $t4 = $zero + 16
        beq     $t1, $t4, CHECKBOARD    # if $t1 == $t4 then UPDATEBOARD
     
		# Check what value is stored at this location 
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		jal		GETARGXY			# jump to GETARGXY and save position to $ra

        # If the space isn't empty, we're done so check the board 
        bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

        # Load our PX and PY value 
        lw      $t0, PX     # 
        lw      $t1, PY     # 

        # We add 1 to PY since we're dropsing some
        addi    $t1, $t1, 1            # $t1 = $t1 + 1
		
        # If we're not done, we store our new pointer
        sw      $t0, PX        # 
        sw      $t1, PY        # 
        	
		# Set our new value to 2 
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		addi	$a2, $zero, 2		# $a2 = $t2 + 2
		jal		SETXY			# jump to SETXY and save position to $ra

        # Load our PX and PY value 
        lw      $t0, PX     # 
        lw      $t1, PY     # 

		#add -1 to PX so working on left side and store
		addi	$t0, $t0, -1

		# Set left new value to 2 
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t1, $zero		# $a1 = $t1 + $zero
		addi	$a2, $zero, 2		# $a2 = $t2 + 2
		jal		SETXY			# jump to SETXY and save position to $ra

        # Load our PX and PY value 
        lw      $t0, PX     # 
        lw      $t1, PY     # 

		# Keep subtracting one to move up the piece unless we hit the top of the board 
		addi	$t2, $zero, 1			# $t2 = $zero + 1

		sub		$t4, $t1, $t2		# $t4 = $t1 - $t2
		beq		$t4, $zero, sloop	# if $t4 == $zero then sloop	
		
		sub		$t4, $t4, $t2		# $t4 = $t4 - $t2

		# Set this value to 0 since we dropsed below it 
		add		$a0, $t0, $zero		# $a0 = $t0 + $zero
		add		$a1, $t4, $zero		# $a1 = $t4 + $zero
		add		$a2, $zero, $zero	# $a2 = $zero + $zero
		jal		SETXY				# jump to SETXY and save position to $ra

		# Also set value of left side to 0 b/c dropsed below
		lw		$t0, PX
		addi	$a0, $t0, -1
		add		$a1, $t4, $zero
		add		$a2, $zero, $zero
		jal		SETXY

        beq     $t4, $zero, sloop   # if $t4 == $zero then sloop

        # After we drop, we print 
        jal     PRINTBOARD       # jump to PRINTBOARD and save position to $ra
        
		# If we make it this far then we are mid drop so we want more input 
		j		sloop				# jump to sloop

	movesr:

		# Load the original PX and PY
		lw		$t0, PX		# 
		lw		$t1, PY		# 

		# Shift our x value to the right once 
		addi	$t2, $zero, 1		# $t3 = $zero + 1
		add		$t0, $t0, $t2		# $t2t = $t0 + $t3
		sw		$t0, PX		# 

		# Initialize some counters 
		addi	$t6, $zero, 2			# $t6 = $zero + 2
		addi	$t5, $zero, 1			# $t5 = $zero + 1

		movesrloop:
			
			# Load 2 into a register since that's what we use for this piece 
			addi	$t2, $zero, 2			# $t3 = $zero + 2
					
			# Set the value at the current position 
			add		$a0, $zero, $t0		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t2		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# Reload X and move it to the previous left side
			lw		$t1, PY
			lw		$t0, PX		# 
			addi	$t0, $t0, -2		# $t0 = $t0 - 2
			
			# We want to set the previous left side to zero 
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We need to set our X and Y back
#			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
#			add		$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, drops	# if $t1 == $zero then drops
			beq		$t5, $t6, drops		# if $t5 == $t6 then drops

			# We need to increase our counter and move our y-value 
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4
					
			j		movesrloop			# jump to movesrloop		

	movesl:

		# Load the original PX and PY
		lw		$t0, PX		# 
		lw		$t1, PY		# 

		# Shift our x value to the left 2 
		addi	$t2, $zero, -2		# $t2 = $zero - 2
		add		$t0, $t0, $t2		# $t0 = $t0 + $t2
		sw		$t0, PX		 

		# Initialize some counters 
		addi	$t6, $zero, 2			# $t6 = $zero + 2
		addi	$t5, $zero, 1			# $t5 = $zero + 1

		moveslloop:
			
			# Load 2 into a register since that's what we use for this piece 
			addi	$t2, $zero, 2			# $t3 = $zero + 2
					
			# Set the value at the current position 
			add		$a0, $zero, $t0		# $a0 = $zero + $t2
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t2		# $a2 = $zero + $t3
			jal		SETXY				# jump to SETXY

			# Reload X and move it to the previous right side
			lw		$t1, PY
			lw		$t0, PX	 
			addi	$t0, $t0, 2			# $t0 = $t0 - 2
			
			# We want to set the previous right side to zero 
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $zero	# $a2 = $zero + $zero
			jal		SETXY				# jump to SETXY and save position to $ra

			# We need to set our X and Y back
#			add		$t0, $a0, $zero		# $t0 = $a0 + $zero
#			add		$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If we're at the top of the board or we're done shifting pieces we wait for the next input
			beq		$t1, $zero, drops	# if $t1 == $zero then drops
			beq		$t5, $t6, drops		# if $t5 == $t6 then drops

			# We need to increase our counter and move our y-value 
			addi	$t4, $zero, 1		# $t4 = $zero + 1
			add		$t5, $t5, $t4		# $t5 = $t5 + $t4
			sub		$t1, $t1, $t4		# $t1 = $t1 - $t4
					
			j		moveslloop			# jump to movesrloop		


.globl CREATEBZ
CREATEBZ:

	# Store our return address on the stack 
	#sw		$ra, 0($sp)		# 

	# We're picking our middle position to be 3 so let's move X there
	# We also want to make sure we're starting at our top row as well 
	addi	$t0, $zero, 3			# $t0 = X + 3 
	addi	$t1, $zero, 0			# $t1 = $zero + 0

	# Store the value for safe keeping
	sw      $t0, PX        # 
	sw      $t1, PY        # 

	#store the first two blocks on the board
	addi	$t2, $zero, 4
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	addi	$t0, $a0, 1
	add	$t1, $zero, $a1
	
	addi	$t2, $zero, 4
	add	$a0, $zero, $t0
	add	$a1, $zero, $t1
	add	$a2, $zero, $t2
	jal	SETXY

	# $t9 holds the rotation state. 1 for vertical, 2 for horizontal 
	addi	$t9, $zero, 2			# $t7 = $zero + 2

	j	bzloop

	bzloop:
		# We want to print our board back to Python 
		jal     PRINTBOARD           # jump to PRINTBOARD and save position to $ra

		# Prompt for user input from Python 
		li        $a0, 1        # $a0 = 1
		li        $v0, 1        # $v0 = 1
		syscall

	# Print a new line
		li      $v0, 4      # system call #4 - print string
		la      $a0, newline    # $a0 = $zero + 15
		syscall             # execute

		# Make MIPS wait for integer input 
		li	$v0, 5		# $v0 = 5	
		syscall				# execute

		# Load PX and PY
		lw	$t0, PX		# 
		lw	$t1, PY		# 

		# A counter for moving pieces 
		addi	$t8, $zero, 1			# $t8 = $zero + 1

		# If Python sends us a 2 we want to shift our piece left
		addi	$t3, $zero, 1			# $t3 = $zero + 2
		beq	$v0, $t3, shiftbzl	# if $v0 == $t3 then shiftbzl

		# If Python sends us a 1 we want to shift our piece right
		addi	$t3, $zero, 2			# $t3 = $zero + 1
		beq	$v0, $t3, shiftbzr	# if $v0 == $t3 then shiftbzr

		# If Python sends us a 3 then we want to rotate the piece 
		addi	$t3, $zero, 3			# $t3 = $zero + 3
		beq	$v0, $t3, rotatebz	# if $v0 == $t3 then rotatebz
		
		# If our piece is in position 1 then drop vertical 
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq	$t9, $t3, dropbzv	# if $t9 == $t3 then dropbzv
		
		# If our piece is in position 2 then drop horizontal 
		addi	$t3, $zero, 2			# $t3 = $zero + 2
		beq	$t9, $t3, dropbzh	# if $t9 == $t3 then dropbzh
		
		# If we get here something is wrong so we wait for another input 
		j	bzloop				# jump to bzloop

	shiftbzl:
	rotatebz:

	shiftbzr:
		addi	$t3, $zero, 1
		beq	$t3, $t9, shiftbzvr
		j	shiftbzhr
		
		shiftbzvr:
			addi	$t7, $zero, 7
			beq	$t0, $t7, dropbzv

			#move one to the right to check for space to move
			addi	$t0, $t0, 1

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back 
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If this position is not free, then we don't want to shift 
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then dropbzv

			#move one up to check for space to move
			addi	$t1, $t1, -1
			
			#check if its still on the board
			blt	$t1, $zero, doshiftbzvr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back 
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If this position is not free, then we don't want to shift 
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv

			#move up one and left one for space to move
			addi	$t0, $t0, -1
			addi	$t1, $t1, -1
		
			#check if its still on the board
			blt	$t1, $zero, doshiftbzvr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back 
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If this position is not free, then we don't want to shift 
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv

		doshiftbzvr:
			# Load PX and PY
			lw	$t0, PX		# 
			lw	$t1, PY		# 

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		# 

			#valueto be stored for the piece
			addi	$t3, $zero, 4

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in middle line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1
			
			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move block in top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1
			
			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero
			
			j	dropbzv

		shiftbzhr:

			addi	$t7, $zero, 5
			bge	$t0, $t7, dropbzh
		
			#check for space to shift in the bottom line
			addi	$t0, $t0, 2
			
			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back 
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If this position is not free, then we don't want to shift 
			bne	$v0, $zero, dropbzh	# if $v0 != $zero then dropbzh

			#check for space to shift in the top line
			addi	$t0, $t0, 1
			addi	$t1, $t1, -1

			#check if its still on the board
			blt	$t1, $zero, doshiftbzhr

			# Get the value stored at PX,PY
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			jal	GETARGXY			# jump to GETARGXY and save position to $ra

			# Get our values of x and y back 
			add	$t0, $a0, $zero		# $t0 = $a0 + $zero
			add	$t1, $a1, $zero		# $t1 = $a1 + $zero
		
			# If this position is not free, then we don't want to shift 
			bne	$v0, $zero, dropbzv	# if $v0 != $zero then droppv
		doshiftbzhr:
			# Load PX and PY
			lw	$t0, PX		# 
			lw	$t1, PY		# 

			#shift the pivot one to the right
			addi	$t0, $t0, 1

			# We want to store this value in PX since it represents the new pivot
			sw	$t0, PX		# 

			#valueto be stored for the piece
			addi	$t3, $zero, 4

			# writing the values in the new spots
			addi	$t0, $t0, 1
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#move blocks in top line
			addi	$t0, $t0, 3
			addi	$t1, $t1, -1
		
			#check if its still on the board
			blt	$t1, $zero, dropbzv

			# writing the values in the new spots
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $t3, $zero		# $a2 = $t3 + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			#erase old spot of pivot
			addi	$t0, $t0, -2
			add	$a0, $t0, $zero		# $a0 = $t0 + $zero
			add	$a1, $t1, $zero		# $a1 = $t1 + $zero
			add	$a2, $zero, $zero	# $a2 = $zero + $zero
			jal	SETXY			# jump to SETXY and save position to $ra
			add	$t0, $a0, $zero
			add	$t1, $a1, $zero

			j	dropbzh
	
	dropbzv:
		#load our PX and PY values
		lw	$t0, PX
		lw	$t1, PY

		#add one to look at the sqare below ours
		addi	$t1, $t1, 1

		#check to make sure we don't go past the bottom of the board
		addi	$t4, $zero, 16
		beq 	$t1, $t4, CHECKBOARD

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back 
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board 
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, -1
		addi	$t1, $t1, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back 
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board 
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		# Load our PX and PY value 
        	lw      $t0, PX     # 
        	lw      $t1, PY     # 

        	# We add 1 to PY since we're dropping some
        	addi    $t1, $t1, 1            # $t1 = $t1 + 1
		
        	# If we're not done, we store our new pointer
        	sw      $t0, PX        # 
        	sw      $t1, PY        # 

		#valueto be stored for the piece
		addi	$t3, $zero, 4

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop left column
		addi	$t0, $t0, -1
		addi	$t1, $t1, 1
		
		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		j	bzloop

	dropbzh:
		#load our PX and PY values
		lw	$t0, PX
		lw	$t1, PY

		#add one to look at the sqare below ours
		addi	$t1, $t1, 1

		#check to make sure we don't go past the bottom of the board
		addi	$t4, $zero, 16
		beq 	$t1, $t4, CHECKBOARD

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back 
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board 
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, 1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back 
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board 
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		#check other hazard spot
		addi	$t0, $t0, 1
		addi	$t1, $t1, -1

		#check what value is stored at this loaction
		add	$a0, $t0, $zero
		add	$a1, $t1, $zero
		jal	GETARGXY

		# Get our values of x and y back 
		add	$t0, $a0, $zero		# $t0 = $a0 + $zero
		add	$t1, $a1, $zero		# $t1 = $a1 + $zero

		# If the space isn't empty, we're done so check the board 
        	bne     $v0, $zero, CHECKBOARD # if $v0 != $zero then CHECKBOARD

		# Load our PX and PY value 
        	lw      $t0, PX     # 
        	lw      $t1, PY     # 

        	# We add 1 to PY since we're dropping some
        	addi    $t1, $t1, 1            # $t1 = $t1 + 1
		
        	# If we're not done, we store our new pointer
        	sw      $t0, PX        # 
        	sw      $t1, PY        # 

		#valueto be stored for the piece
		addi	$t3, $zero, 4

		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot
		addi	$t1, $t1, -1
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop middle column
		addi	$t0, $t0, 1
		addi	$t1, $t1, 1
		
		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -2
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#drop right column
		addi	$t0, $t0, 1
		addi	$t1, $t1, 1
		
		# writing the values in the new spots
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $t3, $zero		# $a2 = $t3 + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		#erase old spot of pivot
		addi	$t1, $t1, -1
		add	$a0, $t0, $zero		# $a0 = $t0 + $zero
		add	$a1, $t1, $zero		# $a1 = $t1 + $zero
		add	$a2, $zero, $zero	# $a2 = $zero + $zero
		jal	SETXY			# jump to SETXY and save position to $ra
		add	$t0, $a0, $zero
		add	$t1, $a1, $zero

		j	bzloop

	
# This is the procedure that is going to handle a lot of our game logic
.globl CHECKBOARD
CHECKBOARD:

	# We want to check the top row of our board
	addi	$t9, $zero, 0			# $t1 = $zero + 0
	addi	$t4, $zero, 0			# $t4 = $zero + 0

	j		toprow				# jump to toprow

	toprow:

		jal		GETINCREMENT		# jump to GETINCREMENT and save position to $ra

		# If any space in the top board is not zero then the game is over
		bne		$v0, $zero, GAMEOVER	# vf $t0 != $zero then GAMEOVER

		# If we hit space 8 on our board then we are on the second row
		addi	$t0, $zero, 8			# $t0 = $zero + 8
		addi	$t9, $t9, 1			# $t1 = $zero + 1
		beq		$t9, $t0, aftertop	# if $t1 == $t0 then aftertop

		j		toprow				# jump to toprow

	aftertop:

		# Grab a value from the board
		jal		GETINCREMENT				# jump to GETINCREMENT and save position to $ra

		# Move the result of GETINCREMENT into a temp register
		add		$t2, $zero, $v0		# $t2 = $zero + $v0

		# If we read the end of the board, then we know we are finsihed checking
		#addi	$t1, $zero, 1			# $t1 = $zero + 1
		#beq		$v0, $t1, finishcheck	# if $v0 == $t1 then target

		# If the space we're looking at is 0 then we know we can't clear the row so we move on
		bne		$t2, $zero, controw	# if $v0 == $t1 then target
		li		$t4, 0
		jal		NEXTROW

		# If our NEXTROW returns 1 then we have also finsihed checking
		addi	$t3, $zero, 1			# $t3 = $zero + 1
		beq		$v0, $t3, finishcheck	# if $v1 == $t3 then finishcheck
	controw:
		# If our counter makes it to 8, then we have to clear this row
		addi	$t4, $t4, 1			# $t4 = $t4 + 1
		addi	$t0, $zero, 8			# $t0 = $zero + 8
		beq		$t4, $t0, clearrow	# if $t0 4= $t0 tclearrowrget

		j		aftertop				# jump to aftertop

	clearrow:
		# Load our X and Y values
		lw		$t0, X		#
		lw		$t1, Y		#

		# Recreate our comparison in case it got erased
		addi	$t4, $zero, 8			# $t4 = $zero + 8

		# We want to make sure we are not looking at the top row, if we are, get out
		addi	$t2, $zero, 0			# $t2 = $zero + 0
		beq		$t1, $t2, CHECKBOARD	# if $t1 == $t2 then CHECKBOARD

		# Set X to zero to start at the beginning of the row
		add		$t0, $zero, $zero		# $t0 = $zero + $zero

		# We want to move one row above our current row and store it in another register
		addi	$t3, $zero, 1		# $t3 = $zero + 1
		sub		$t2, $t1, $t3		# $t2 = $t1 - $t2

		clearloop:
			add		$t7, $zero, $t1
			# Call GETARGXY to get the value stored at our position
			add		$a0, $zero, $t0		# $a0 = $zero + $t0
			add		$a1, $zero, $t2		# $a1 = $zero + $t2
			jal		GETARGXY				# jump to GETARGXY and save position to $ra

			add		$t0, $zero, $a0
			add		$t2, $zero, $a1
			add		$t1, $zero, $t7
			add		$t6, $zero, $v0

			# Call SETXY to set our new value
			add		$a0, $zero, $t0
			add		$a1, $zero, $t1		# $a1 = $zero + $t1
			add		$a2, $zero, $t6		# $a2 = $zero + $v0
			jal		SETXY				# jump to SETXY and save position to $ra

			add		$t0, $zero, $a0
			add		$t1, $zero, $a1

			# Move to the next column
			addi	$t0, $t0, 1			# $t0 = $t0 + 1
			beq		$t0, $t4, finclearloop	# if $t0 == $t4 then finclearloop

			j		clearloop				# jump to clearloop

		finclearloop:
			sw		$t2, Y		#
			j		clearrow				# jump to clearrow

	finishcheck:
		j		UPDATEBOARD				# jump to UPDATEBOARD


.globl GAMEOVER
GAMEOVER:
	# When the game ends, we write a 9 to STDOUT to tell Python we're done as well
	li		$v0, 1		# system call #4 - print string
	addi	$a0, $zero, 9			# $a0 = $zero + 9
	syscall				# execute

	# Print a new line
    li      $v0, 4      # system call #4 - print string
    la      $a0, newline    # $a0 = $zero + 15
    syscall             # execute

	li		$v0, 10			# Syscall to end program 
	syscall
