
	.equ COEF1, 3483
	.equ COEF2, 11718
	.equ COEF3, 1183

	.text


	.global rgb2gray
	.global div16384

//----------------------RGB2GRAY ARM METHOD----------------------------------//
// PARAM R0		: DIRECCION DE UN ELEMENTO PIXELRGB DE 3 UNSIGNED CHAR
// RETURN R0	: unsigned char
rgb2gray:
	PUSH {R4-R6,LR}
	LDR R4, =COEF1
	LDR R5, =COEF2
	LDR R6, =COEF3

	LDRB R1,[R0]		//ALMACENA VALOR DE R (LITTLE ENDIAN)
	MUL R2,R1,R4		//R2 = R*COEF1

	LDRB R1,[R0,#1]		//ALMACENA VALOR DE G (LITTLE ENDIAN)
	MUL R3,R1,R5		//R3 = G*COEF2

	ADD R2,R2,R3		//R2 = R*COEF1 + G*COEF2

	LDRB R1,[R0#2]		//ALMACENA VALOR DE B (LITTLE ENDIAN)
	MUL R3,R1,R6		//R3 = B*COEF3

	ADD R2,R2,R3		//R2 = R*COEF1 + G*COEF2 + B*COEF3
	MOV R0,R2

	BL div16384			//PARAMETRO POR R0
	POP {R4-R6,LR}
	MOV PC,LR			//FIN, RESULTADO EN R0

div16384: 
	MOV R0,R0,LSR #14	//16384 == 2^14, DESPLAZAR BITS
	MOV PC,LR

//----------------------GAUSSIAN ARM METHOD----------------------------------//
/*
void apply_gaussian(unsigned char im1[], unsigned char im2[], int width, int height)
{
	int i,j;
	for(i =0 ; i< width; i++)
		for(j =0 ; j< height; j++)
			im2[i*width + j] = gaussian(im1,width,height,i,j);
}
*/
apply_gaussian:
		PUSH {R4-R8}
		//R0 direccion im1
		//R1 direccion im2
		//R2 width
		//R3 height
		MOV R4,#0				//R4 i

for1:	CMP R4,R2				//i< width
		BGE finfor1
		MOV R5,#0				//R5 j
for2:	CMP R5,R3				//j< height
		BGE finfor2

		PUSH {R0-R4,LR}
		MOV R1,R2
		MOV R2,R3
		MOV R3,R4
		MOV R4,R5

		PUSH {R4}				//Guardamos en pilaR4 para que entre a SUBRUTINA como 5ªPARAM
		MOV LR,PC
		BL gaussian
		POP {R4}

		MOV R7,R0				//R7 return gaussian
		POP {R0-R4,LR}

		MUL R8,R4,R2			//i* width
		ADD R8,R8,R5			//R8=(i*width) + j
		STRB R7,[R1,R8,LSL#0]	//im2[i*width + j] = gaussian(im1,width,height,i,j);
		ADD R5,R5,#1			//CONTADOR J++
		B for2

finfor2:
		ADD R4,R4,#1	//CONTADOR i++
		B for1

finfor1:
		POP {R4-R8}
		MOV PC,LR
		B .

  		.end


