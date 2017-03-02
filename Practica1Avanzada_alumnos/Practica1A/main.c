/*
 * Practica 1 de Estructura de Computadores
 * Grupo 2º C, LAB 8 PTO 12
 * Facultad de Informática de la Complutense
 *
 *
 * Alumnos:
 *
 * Diego Valbuena Pineda
 * Enrique Julio de la Cruz Valderrama
 */



#include <stdio.h>
#include "trafo.h"
#include "types.h"
#include "time.h"
#include "lena512color.h"
extern void apply_gaussian(unsigned char im1[], unsigned char im2[], int width, int height);
extern void suma(unsigned char im1[],int width);


// la imagen de LENA
#define LENA

#ifdef LENA
#define N 512
#define M 512
pixelRGB* imagenRGB;
#else
#define N 512
#define M 512
pixelRGB imagenRGB[N*M];
#endif

unsigned char imagenGris[N*M];
unsigned char imagenGauss[N*M];
unsigned char imagenSobel[N*M];

#ifndef LENA
void initRGB(int nfilas, int ncols)
{
    int i,j;

    for (i=0;i<nfilas;i++)
        for (j=0; j<ncols; j++) {
        	imagenRGB[i*ncols+j].R = (i+j)%256;
        	imagenRGB[i*ncols+j].G = (i+j)%256;
        	imagenRGB[i*ncols+j].B = (i+j)%256;
        }
}
#else
void initRGB(int nfilas, int ncols)
{
    imagenRGB = (pixelRGB*) imageLena512;
}
#endif


int main() {
	short int time = 0;
    timer_init();
    initRGB(N,M);
    timer_start();
    RGB2GrayMatrix(imagenRGB, imagenGris,N,M);
    suma(imagenGris,N);
    apply_gaussian(imagenGris, imagenGauss, N, M);
    apply_sobel(imagenGauss, imagenSobel, N, M);
    time = timer_stop();
    return 0;
}
