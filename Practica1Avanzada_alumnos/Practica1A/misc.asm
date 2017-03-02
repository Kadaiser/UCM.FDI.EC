	.global rgb2gray
	.global apply_gaussian
	.extern gaussian
	.global suma
	.extern media

.data


.bss
vmedia: 	.space 1


	.text

//----------------------RGB2GRAY ARM METHOD----------------------------------//
// PARAM R0		: DIRECCION DE UN ELEMENTO PIXELRGB DE 3 UNSIGNED CHAR
// RETURN R0	: unsigned char
rgb2gray:
		PUSH {R4 - R6, LR}
		LDR R4, =3483
		LDR R5, =11718
		LDR R6, =1183

		LDRB R1,[R0]				//R1 almacena el valor del elemento R (LITTLE ENDIAN)
		MUL R2,R1,R4				//R2 = R*3483

		LDRB R1,[R0,#1] 			//R1 almacena el valor del elemento G (LITTLE ENDIAN)
		MUL R3,R1,R5				//R3 = G*11718

		ADD R2,R2,R3				//R2 = (R*3483) + (G*11718)
		LDRB R1,[R0,#2] 			//R1 almacena el valor del elemento B (LITTLE ENDIAN)
		MUL R3,R1,R6				//R3 = G*1183

		ADD R2,R2,R3				//R2 = (R*3483) + (G*11718) + (B*1183)
		MOV R0,R2
		BL div16384				//LLAMADA A SUBRUTINA R0 = (R*3483) + (G*11718) + (B*1183)
		POP {R4 - R6, LR}
		MOV PC, LR					// R0 = ( (R*3483) + (G*11718) + (B*1183) )/16384

div16384:
		  mov r0, r0, lsr #14		//aprovechamos que es potencia de 2 ^14r
		  mov pc, lr

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
		PUSH {R4-R8,LR}
		//R0 direccion im1
		//R1 direccion im2
		//R2 width
		//R3 height
		MOV R4,#0			//R4 i

for1:	CMP R4,R2			//i< width
		BGE finfor1
		MOV R5,#0			//R5 j
for2:	CMP R5,R3			//j< height
		BGE finfor2

		PUSH {R0-R4}
		MOV R1,R2
		MOV R2,R3
		MOV R3,R4
		MOV R4,R5

		PUSH {R4}	//Guardamos en pilaR4 para que entre a SUBRUTINA como 5ªPARAM
		MOV LR,PC
		BL gaussian
		POP {R4}

		MOV R7,R0	//R7 return gaussian
		POP {R0-R4}

		MUL R8,R4,R2			//i* width
		ADD R8,R8,R5			//R8=(i*width) + j
		STRB R7,[R1,R8]	//im2[i*width + j] = gaussian(im1,width,height,i,j);
		ADD R5,R5,#1			//CONTADOR J++
		B for2

finfor2:
		ADD R4,R4,#1	//CONTADOR i++
		B for1

finfor1:
		POP {R4-R8,LR}
		MOV PC,LR

  /*/----------------------SUMA ARM METHOD----------------------------------//

  void suma (im1,width){
int i,j;
int sum=0; 				//Definir en r4
int num=0; 				//Definir en r5
int vmedia;
for (i=0;i<width;i++){
	for(j=0;j<width;j++){
		sum=sum+im1[i*width+j];
		num=num+1;
	}
}
	vmedia=media(unsigned char sum,unsigned char num);
 */

 //R0 direccion de la imagen
 //r1 entero width
 suma:
 		PUSH {R4-R9,LR}
		//R0 direccion im1
		//R1 width

		MOV R4,#0			//R4 suma
		MOV R5,#0			//R5 num
		MOV R2,#0			//R2 = i <= 0;

for1suma:	CMP R2,R1			//i< width
		BGE finfor1suma
		MOV R3,#0			//R3 = j <= 0;
for2suma:	CMP R3,R1			//j< height
		BGE finfor2suma

		MLA R6,R1,R2,R3			// R6 = (i* width)+j
		LDRB R7,[R0,R6]	//R7 = im1[i*width+j];
		ADD R4,R4,R7			//sum= sum + im1[i*width+j];
		ADD R5,R5,#1			//num++

		ADD R3,R3,#1			//CONTADOR j++
		B for2suma

finfor2suma:
		ADD R2,R2,#1	//CONTADOR i++
		B for1suma

finfor1suma:

		MOV R8,#0		//R8 = vmedia <= 0

		PUSH {R0-R3}
		/*parametros
		R0 direccion im1
		R1 int num
		*/
		MOV R0,R4
		MOV R1,R5
		BL media
		MOV R8,R0		//R8 return vmedia
		POP {R0-R3}

		LDR R9, = vmedia //direccion de vmedia
		STR R8,[R9]		//guardar valor vmedia

		POP {R4-R9,LR}
		MOV PC,LR


    .end
