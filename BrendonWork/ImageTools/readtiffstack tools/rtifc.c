/*
 * RTIFC.MEX
 * 
 * This is a mex interface to the Sam Leffler's LIBTIFF library which
 * will allow many variants of TIFF images to be read.
 * 
 * The syntaxes are:
 *
 *     RGB = rtifc (filename) 
 *     GRAY = rtifc (filename)
 *     SAMPLES = rtifc (filename)
 *     [X,map] = rtifc (filename)
 *     ... = rtifc (filename, n)
 *   
 * RGB is a mxnx3 uint8 array containing the 24-bit image stored in
 * the tiff file filename.     
 * 
 * GRAY is a mxn uint8 array containing the grayscale image stored in
 * the tiff file filename.   
 *
 * SAMPLES is an mxnxp uint8 or uint16 array containing the 8 or 16-bit
 * data stored in in a multisample image (such as CMYK).  "p" is the
 * number of samples in the image.
 *
 * X is an mxn uint8 array containing indices into the colormap map,
 * which is returned as uint16 (unsigned short).       
 *
 * Read the image from the n'th directory in the TIFF file.   When n is
 * not specified, the default is to read from the first directory in
 * the file.  
 *
 * KNOWN BUGS:
 * -----------
 *    Reading Thunderscan compression isn't correctly implemented yet. 
 *    
 * ENHANCEMENTS UNDER CONSIDERATION:
 * ---------------------------------
 *    Reading Tiled images isn't implemented yet.
 * 
 * 
 * Sam  Leffler's LIBTIFF library, version 3.4 is available from:
 * ftp://ftp.sgi.com/graphics/tiff/tiff-v3.4-tar.gz
 *
 * Chris Griffin, June 1996
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.1.1 $  $Date: 2005/03/01 18:12:00 $
 */

static char rcsid[] = "$Id: rtifc.c,v 1.1.1.1 2005/03/01 18:12:00 brendon Exp $";


#include "mex.h"
#include <stdio.h>
#include <string.h>
#include "tiffio.h"

/* Different types of images we can read: */
#define BINARY_IMG 0
#define GRAY_IMG   1
#define INDEX_IMG  2
#define RGB_IMG    3
#define RGBA_IMG   4

/* Buffer for error handler */
static char *ERROR_BUFFER;

/* Subroutines */
static void ErrHandler(const char *, const char *, va_list);
static void WarnHandler(const char *, const char *, va_list);
static void CloseAndError(TIFF *);
static void StuffContigTileBufferIntoRGB(TIFF*,uint8_T*,int,int,uint8_T*,uint8_T*,uint8_T*);
static void getNthKbitNumberFromScanline(void *,int,int,uint8_T *);
static mxArray *GetColormap(TIFF* , uint16_T);
static mxArray *ReadIndexedGrayOrBinaryImage(TIFF *);
static mxArray *ReadRGBImage(TIFF *);
static mxArray *ReadNSampleImage(TIFF *);


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) { 
  TIFF *tif;
  mxArray *outArray, *cmap;
  char *filename;
  int buflen;
  int dirnum=1;
  int imageType=-1;                
  uint16 photo,spp,bps;
  uint16 compressionType;
  char errmsg[1024];
/*  int dircount; */

  ERROR_BUFFER = NULL;  /* Reset error buffer */
  TIFFSetErrorHandler(ErrHandler);
  TIFFSetWarningHandler(WarnHandler);

  if (nrhs < 1)
  {
      mexErrMsgTxt("Not enough input arguments.");
  }      
  if (nrhs > 2)
  {
      mexErrMsgTxt("Too many input arguments.");
  }
  if (nlhs > 2)
  {
      mexErrMsgTxt("Too many output arguments.");
  }
  if(! mxIsChar(prhs[0]))
  {
      mexErrMsgTxt("First argument is not a string.");
  }

  buflen = mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar) + 1;
  filename = (char *) mxCalloc(buflen, sizeof(*filename));
  mxGetString(prhs[0],filename,buflen);  /* First argument is the filename */
  
  if(nrhs == 2)  /* The second arg is the directory number to read from */
  {
      dirnum = (int) mxGetScalar(prhs[1]);
  }

/*
 * Open tiff file
 */

  if ((tif = TIFFOpen(filename, "ru")) == NULL) {
      if (ERROR_BUFFER != NULL)
          mexErrMsgTxt(ERROR_BUFFER);
      else
          mexErrMsgTxt("Couldn't open file");
  }
  mxFree((void *) filename);


#if 0
/* This section of code is commented out because TIFFReadDirectory()
 * chokes on the bad TIFF directories that tifwrite produced in
 * IPT version 1.  We still want to be able to read those files.
 * IMREAD will check the length of the info structure to make sure
 * the specified dirnum is valid.  -sle, 6/24/96
 */

/*
 * Count the number of images in the file, even though for now we will
 * only read the first one.
 */

  if (tif) {
      dircount = 0;
      do {
          dircount++;
      } while (TIFFReadDirectory(tif));
  }

#endif /* 0 */

  if(dirnum == 0)
  {
      TIFFClose(tif);
      mexErrMsgTxt("The first image directory is chosen with index 1, not 0.");
  }      

#if 0
/* See comment above */
  else if(dirnum > dircount)
  {
      TIFFClose(tif);
      sprintf(errmsg, "Cannot read directory number %d since %.900s only contains %d directories.\n", dirnum, filename, dircount);
      mexErrMsgTxt(errmsg);
  }
#endif /* 0 */

  /* The first directory is dirnum == 0! */
  if (! TIFFSetDirectory(tif, (uint16_T) (dirnum-1)))
  {
      TIFFClose(tif);
      mexErrMsgTxt("Invalid TIFF image index specified.");
  }
  
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
  TIFFGetField(tif, TIFFTAG_PHOTOMETRIC, &photo);
  TIFFGetField(tif, TIFFTAG_COMPRESSION, &compressionType);
  TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
  TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);

  if (compressionType == COMPRESSION_LZW)
  {
      TIFFClose(tif);
      mexErrMsgTxt("LZW-compressed TIFF images are not supported.");
  }
  
  /*
   * Figure out the image type: Binary, RGB, RGBA, index, ...
   */
  
  if(photo == 3)                 /* Palette-Colormap Image */
  {
      if (nlhs > 1)
      {
          cmap = GetColormap(tif,bps);
          plhs[1] = cmap;
      }
      outArray = ReadIndexedGrayOrBinaryImage(tif);
  }
  
  else if(photo == 2)                   /* RGB Image */
  {
      outArray = ReadRGBImage(tif);
  }      

  else if(photo == 5)                   /* CMYK Image */
  {

      if(spp < 4)
      {
          sprintf(errmsg,"CMYK image has %d (not 4) samples per pixel.",spp);
          TIFFClose(tif);
          mexErrMsgTxt(errmsg);
      } else if (spp > 4) {
          sprintf(errmsg,"CMYK image has %d (not 4) samples per pixel.",spp);
          mexWarnMsgTxt(errmsg);
      }
      
      outArray = ReadNSampleImage(tif);
         
  }

  else if(photo == 0 | photo == 1)      /* Gray or Binary image */
  {
      outArray = ReadIndexedGrayOrBinaryImage(tif);
  }
  
  else                                  /* Other image type */
  {
    outArray = ReadNSampleImage(tif);
  }
  
  TIFFClose(tif);

/*
 * Give the mexfile output arguments by making the
 * pointer to left hand side point to the output array.
 */

  plhs[0]=outArray; 

  if ( (nlhs > 1) && (plhs[1] == NULL) )
      plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
  
  return;		
}


/*
** ReadIndexedGrayOrBinaryImage
** 
** This subroutine will read the image data from the TIFF file and return it
** in a MATLAB array.  The image type should be either Indexed, Grayscale or
** Binary.  This routine doesn't do anything with colormaps.
** For Grayscale, it can read 8 or 16 bit images.  I think it will read
** a 16 bit Indexed image, but I could never create or find one to test
** with.
*/

static mxArray *
ReadIndexedGrayOrBinaryImage(TIFF *tif)             /* Grayscale, Binary, or Indexed Image */
{
    mxLogical *ptrLogical;
    uint8_T  *ptrUint8, out8;
    uint16_T *ptrUint16, out16;
    uint32_T *ptrUint32, out32;
    real32_T *ptrFloat32;
    mxArray *outArray;
    int pixmax;             /* Maximum allowable pixel value (1<<bps)-1 */
    unsigned long row,col,imcol;
    uint16 bps,spp,photo,sampleFormat=SAMPLEFORMAT_UINT;
    unsigned int scanlineSize, bit;
    uint32 imageWidth,imageHeight;         /* image width, height */
    int dims[3];         /* For the calls to mxCreateNumericArray */
    uint8_T bytebuffer[8];
    uint8_T   *scanline8, *scanline16, *scanline32;
    uint16_T  *buf_int_16;
    uint32_T  *buf_int_32;
    real32_T  *buf_float_32;

  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_PHOTOMETRIC, &photo);
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &imageWidth);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imageHeight);
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);
    TIFFGetField(tif, TIFFTAG_SAMPLEFORMAT, &sampleFormat);


    /* 
     *  Comment out the following four lines to enable reading of N-bit UINT packed 
     *  images (16<N<32), 32 bit integer and 32 bit floating point images          
     */


    if(bps>16) {
        TIFFClose(tif);
        mexErrMsgTxt("Cannot read images with greater than 16 bits per sample.");
    }

  
    dims[0]  = imageHeight;                 /* Image Height */
    dims[1]  = imageWidth;                 /* Image Width  */
    dims[2]  = 1;
    
    pixmax = (1<<bps)-1;          /* Maximum allowable pixel value */

    if(sampleFormat==SAMPLEFORMAT_IEEEFP) {
        if (bps==32) {
            outArray = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, mxREAL); 
            ptrFloat32 = (real32_T *) mxGetData(outArray);
        }
        else {
            TIFFClose(tif);
            mexErrMsgTxt("Unsupported bit-depth for IEEE floating point data.");
        }
    }
    else {  
        /* It must be a SAMPLEFORMAT_UINT.  I don't explicitly test for this
        ** due to a bug in LIBTIFF where it doesn't always return the right
        ** value for SAMPLEFORMAT_UINT. */
	if(bps == 1) {
	    outArray = mxCreateLogicalArray(2, dims);
	    ptrLogical = mxGetLogicals(outArray);
	} else if (bps>1 && bps<=8) {
            outArray = mxCreateNumericArray(2, dims, mxUINT8_CLASS, mxREAL); 
            ptrUint8 = (uint8_T *) mxGetData(outArray);
        } 
        else if (bps>8 && bps<=16) {
            outArray = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL); 
            ptrUint16 = (uint16_T *) mxGetData(outArray);
        }
        else if (bps>16 && bps<=32) {
            outArray = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL); 
            ptrUint32 = (uint32_T *) mxGetData(outArray);
        }
        else {
            TIFFClose(tif);
            mexErrMsgTxt("Unsupported bit-depth for integer image data.");
        }
    }
    
    if(TIFFIsTiled(tif)){
        TIFFClose(tif);
        mexErrMsgTxt("Tiled TIFF images are not supported");
    }


    /* Image is organized in strips */
    scanlineSize = TIFFScanlineSize(tif);


    /* 8-bit Gray or Indexed */
    if(bps == 8)          
    {
        scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(mxUINT8_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) /* White is Zero - complement */
                    ptrUint8[row+(col*imageHeight)] = (pixmax)-scanline8[col];
                else          /* Black is zero */
                    ptrUint8[row+(col*imageHeight)] = scanline8[col];
            }
        }        
        mxFree(scanline8);
    }
    
    /* 16-bit Grayscale or Indexed */
    else if (bps == 16)   
    {
        buf_int_16 = (uint16_T *) mxCalloc(scanlineSize, sizeof(mxUINT16_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, buf_int_16, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) /* White is Zero - complement */
                    ptrUint16[row+(col*imageHeight)] = (pixmax)-buf_int_16[col];
                else          /* Black is zero */
                    ptrUint16[row+(col*imageHeight)] = buf_int_16[col];
            }
        }        
        mxFree(buf_int_16);
    }
    
    /* 32-bit Grayscale */
    else if ((bps == 32) && (sampleFormat!=SAMPLEFORMAT_IEEEFP))
    {
        buf_int_32 = (uint32_T *) mxCalloc(scanlineSize, sizeof(mxUINT32_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, buf_int_32, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) /* White is Zero - complement */
                    ptrUint32[row+(col*imageHeight)] = (pixmax)-buf_int_32[col];
                else          /* Black is zero */
                    ptrUint32[row+(col*imageHeight)] = buf_int_32[col];
            }
        }        
        mxFree(buf_int_32);
    }
    
    /* 32 bit floating point grayscale image */
    else if ((bps == 32) && (sampleFormat==SAMPLEFORMAT_IEEEFP))
    {
        buf_float_32 = (real32_T *) mxCalloc(scanlineSize, sizeof(mxSINGLE_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, buf_float_32, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0; col < imageWidth; col++)
            {
                if (photo==0) { /* White is Zero - complement */
                    TIFFClose(tif);
                    mexErrMsgTxt("Floating point TIFF file has Photometric 0 (White is 0).");
                }
                else          /* Black is zero */
                    ptrFloat32[row+(col*imageHeight)] = buf_float_32[col];
            }
        }        
        mxFree(buf_float_32);
    }

    else if (bps == 4)
    {
        scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(mxUINT8_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                CloseAndError(tif);

            for (col = 0, imcol = 0; col < scanlineSize; col++)
            {
                if (imcol < imageWidth)
                {
                    ptrUint8[row + imcol*imageHeight] = 
                        (scanline8[col] >> 4) & 0x0F;
                    imcol++;
                }
                if (imcol < imageWidth)
                {
                    ptrUint8[row + imcol*imageHeight] =
                        (scanline8[col] & 0x0F);
                    imcol++;
                }
            }
        }
        mxFree(scanline8);
    }

    /* Binary */
    else if(bps == 1)     
    {
        /* Read the binary image into an 8-bit MATLAB array */
        scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(mxUINT8_CLASS));
        for (row = 0; row < imageHeight; row++)
        {
            if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                CloseAndError(tif);

            for(col=0; col < scanlineSize; col++)
            {
                
                if(photo==0) /* White is zero */
                    for(bit=0;bit<8;bit++)
                    {
                        bytebuffer[7-bit] = ! ((scanline8[col]>>bit) & 1);
                    }
                else      /* Black is zero */
                    for(bit=0;bit<8;bit++)
                    {
                        bytebuffer[7-bit] = (scanline8[col]>>bit) & 1;
                    }                          
                
                for(bit=0; bit<8 && (8*col+bit)<imageWidth; bit++)
                {
                    ptrLogical[row+((8*col+bit)*imageHeight)] = bytebuffer[bit];
                }
            }
        }
        mxFree(scanline8);
    }


    /* Tightly packed non-standard integer sizes, for example: 11-bit Grayscale Kodak images */
    else if(bps<32)   
    {
        /* Allocate a scanline of the appropriate size */

        if (bps>1 && bps<8)   /* We're using uint8's */
            scanline8 = (uint8_T *) mxCalloc(scanlineSize, sizeof(uint8_T));
        else if(bps>8 && bps<16) /* We're using uint16's */
            scanline16 = (uint8_T *) mxCalloc(scanlineSize, sizeof(uint16_T));
        else if(bps>16 && bps<32) /* We're using uint32's */
            scanline32 = (uint8_T *) mxCalloc(scanlineSize, sizeof(uint32_T));

        /* Read the data into scanline, and copy it to the output array */

        for (row = 0; row < imageHeight; row++)
        {

            if (bps>1 && bps<8) {  /* We're using uint8's */
                if (TIFFReadScanline(tif, scanline8, row, 0) == -1)
                    CloseAndError(tif);

                for(col=0; col < imageWidth; col++) 
                {
                    getNthKbitNumberFromScanline(&out8, col, bps, scanline8);
                    if (photo==0) /* White is Zero - complement */
                        ptrUint8[row+(col*imageHeight)] = (pixmax)-(out8); 
                    else          /* Black is zero */
                        ptrUint8[row+(col*imageHeight)] = out8; 
                }
            }
            
            else if(bps>8 && bps<16) { /* We're using uint16's */
                if (TIFFReadScanline(tif, scanline16, row, 0) == -1)
                    CloseAndError(tif);

                for(col=0; col < imageWidth; col++)  
                {
                    getNthKbitNumberFromScanline(&out16, col, bps, scanline16);                    
                    if (photo==0) /* White is Zero - complement */
                        ptrUint16[row+(col*imageHeight)] = (pixmax)-(out16); 
                    else          /* Black is zero */
                        ptrUint16[row+(col*imageHeight)] = out16; 
                }
            }

            else if(bps>16 && bps<32) { /* We're using uint32's */
                if (TIFFReadScanline(tif, scanline32, row, 0) == -1)
                    CloseAndError(tif);

                for(col=0; col < imageWidth; col++)  
                {
                    getNthKbitNumberFromScanline(&out32, col, bps, scanline32);                    
                    if (photo==0) /* White is Zero - complement */
                        ptrUint32[row+(col*imageHeight)] = (pixmax)-(out32); 
                    else          /* Black is zero */
                        ptrUint32[row+(col*imageHeight)] = out32; 
                }
            }
        }
        
        if (bps>1 && bps<8)   
            mxFree(scanline8);
        else if(bps>8 && bps<16)
            mxFree(scanline16);
        else if(bps>16 && bps<32)
            mxFree(scanline32);
    }
    
    return outArray;
}

/*
** getNthKbitNumberFromScanline
**
** getNthKbitNumberFromScanline(void *out, int n, int bps, uint8_T *scanline)
** INPUTS:
**    void *out  - this is the integer (uint8, uint16, or uint32) which we
**                 will be writing to.
**    int n      - We will get the n'th integer from the scanline. n=0 gets
**                 the first integer.
**    int bps    - This is k, or the number of bits per integer we are 
**                 getting.
**    uint8 scanline - the scanline
*/

static void
getNthKbitNumberFromScanline(void *out, int n, int bps, uint8_T *scanline)
{
    uint8_T *out8, temp8, bit;
    uint16_T *out16;
    uint32_T *out32;
    uint32_T byteIdx;
    int  bitIdx;
    int i;
    
    byteIdx = n * bps / 8;         /* the first byte we will be looking at */
    bitIdx = 7 - ((n * bps) % 8);  /* index of the bit within byte byteIdx */

    /* Case 1: The output is stored in uint8's */
    if(bps>=1 && bps<=8) {
        out8 = (uint8_T *) out;     /* out8 points to the same integer as out */
        *out8 = 0;                  /* Make sure we start out with a bunch of 0's */
        temp8 = scanline[byteIdx];

        for(i=bps-1; i>=0; i--) {
            bit = (temp8>>bitIdx) & (uint8_T) 1;       /* get bit from scanline */
            *out8 =  *out8 | (bit << i);                  /* put bit into output integer */
            bitIdx--;

            /* See if we crossed a byte boundary */
            if(bitIdx<0) {
                bitIdx = 7;
                byteIdx++;
                temp8 = scanline[byteIdx];
            }
        }
    }
    
    /* Case 2: The output is stored in uint16's */
    else if(bps>8 && bps<=16) {
        out16 = (uint16_T *) out; 
        *out16 = 0;               
        temp8 = scanline[byteIdx]; 

        for(i=bps-1; i>=0; i--) {
            bit = (temp8>>bitIdx) & (uint8_T) 1;       /* get bit from scanline */
            *out16 = *out16 | (bit << i);                /* put bit into output integer */
            bitIdx--;

            /* See if we crossed a byte boundary */
            if(bitIdx<0) {
                bitIdx = 7;
                byteIdx++;
                temp8 = scanline[byteIdx];
            }
        }
    }

    /* Case 3: The output is stored in uint32's */
    else if(bps>16 && bps<=32) {
        out32 = (uint32_T *) out; /* out32 points to the same integer as out */
        *out32 = 0;               /* Meke sure we start out with a bunch of 0's */
        temp8 = scanline[byteIdx]; 

        for(i=bps-1; i>=0; i--) {
            bit = (temp8>>bitIdx) & (uint8_T) 1;       /* get bit from scanline */
            *out32 = *out32 | (bit << i);                /* put bit into output integer */
            bitIdx--;

            /* See if we crossed a byte boundary */
            if(bitIdx<0) {
                bitIdx = 7;
                byteIdx++;
                temp8 = scanline[byteIdx];
            }
        }
    }
    else
        mexErrMsgTxt("Too many bits-per-sample for packed integer data.");
}

/*
** ReadRGBImage
** 
** This subroutine will read the image data from the TIFF file and return it
** in a MATLAB array.  The image type should be RGB Truecolor, 8 or 16 bits.
*/

static mxArray *
ReadRGBImage(TIFF *tif)             /* RGB Image */
{
    uint8_T  *ptrRed8,  *ptrGreen8,  *ptrBlue8;  /* RGB arrays */
    uint16_T *ptrRed16, *ptrGreen16, *ptrBlue16;
    mxArray *outArray;
    uint32_T i,j,row,col;
    uint16 bps,spp,config,sampleFormat;
    uint32 imageWidth,imageHeight;                   /* image width, height */
    int dims[3];         /* For the calls to mxCreateNumericArray */
    char errmsg[1024];
    unsigned int scanlineSize;
    uint8_T *buf_8;
    uint16_T *buf_16;
    
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH,  &imageWidth);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imageHeight);
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);
    TIFFGetField(tif, TIFFTAG_PLANARCONFIG, &config);
    TIFFGetField(tif, TIFFTAG_SAMPLEFORMAT, &sampleFormat);

    if(spp < 3)
    {
        sprintf(errmsg,"RGB image has %d (not 3) samples per pixel.",spp);
        TIFFClose(tif);
        mexErrMsgTxt(errmsg);
    } else if (spp > 3) {
        sprintf(errmsg,"RGB image has %d (not 3) samples per pixel.",spp);
        mexWarnMsgTxt(errmsg);
    }

    dims[0]  = imageHeight;                /* Image Height */
    dims[1]  = imageWidth;                 /* Image Width  */
    dims[2]  = spp;                        /* Color planes */
    
    if(TIFFIsTiled(tif)) {
        TIFFClose(tif);
        mexErrMsgTxt("Tiled TIFF images are not supported");
    }

    /* Image is organized in strips */
    scanlineSize = TIFFScanlineSize(tif);


    if (bps==8) {
        outArray = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL); 
        ptrRed8   = (uint8_T *) mxGetData(outArray);
        ptrGreen8 = ptrRed8 + (imageHeight*imageWidth);
        ptrBlue8  = ptrRed8 + (2*imageHeight*imageWidth);
    } else if (bps==16) {
        outArray = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL); 
        ptrRed16   = (uint16_T *) mxGetData(outArray);
        ptrGreen16 = ptrRed16 + (imageHeight*imageWidth);
        ptrBlue16  = ptrRed16 + (2*imageHeight*imageWidth);
    } else {
        TIFFClose(tif);
        mexErrMsgTxt("Unsupported bit-depth for RGB TIFF image file.");
    }

         
    if(config==PLANARCONFIG_CONTIG)   {
        /* Chunky mode - RGBRGBRGB... */

        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_8, row, 0) == -1)
                    CloseAndError(tif);

                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    ptrRed8[j]   = buf_8[col*spp];    /* If there is alpha-channel in the */
                    ptrGreen8[j] = buf_8[col*spp+1];  /* fourth pixel (spp = 4), this should*/
                    ptrBlue8[j]  = buf_8[col*spp+2];  /* just skip right over it */
                }
            }          
            mxFree(buf_8);
        } 

        else if (bps==16) {
            buf_16 = (uint16_T *) mxCalloc(scanlineSize, sizeof(uint16_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_16, row, 0) == -1)
                    CloseAndError(tif);

                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    ptrRed16[j]   = buf_16[col*spp];    /* If there is alpha-channel in the */
                    ptrGreen16[j] = buf_16[col*spp+1];  /* fourth pixel (spp = 4), this should*/
                    ptrBlue16[j]  = buf_16[col*spp+2];  /* just skip right over it */
                }
            }          
            mxFree(buf_16);
        }   
    }
    else if(config == PLANARCONFIG_SEPARATE)   {
          /* Planar format - RRRRRR...  GGGGG... BBBBB.... */

        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_8, row, (uint16_T) i) == -1)
                        CloseAndError(tif);

                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        switch(i) /* Figure out which plane we are in */
                        {
                        case 0:
                            ptrRed8[j] = buf_8[col];
                            break;
                        case 1:
                            ptrGreen8[j] = buf_8[col];
                            break;
                        case 2:
                            ptrBlue8[j] = buf_8[col];
                            break;
                        }
                    }
                }   
            mxFree(buf_8);
        }
        else if (bps==16) {
            buf_16 = (uint16_T *) mxCalloc(scanlineSize,sizeof(uint16_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_16, row, (uint16_T) i) == -1)
                        CloseAndError(tif);

                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        switch(i) /* Figure out which plane we are in */
                        {
                        case 0:
                            ptrRed16[j] = buf_16[col];
                            break;
                        case 1:
                            ptrGreen16[j] = buf_16[col];
                            break;
                        case 2:
                            ptrBlue16[j] = buf_16[col];
                            break;
                        }
                    }
                }   
            mxFree(buf_16);
        }
    }
    return outArray;
}


/*
** ReadNSampleImage
** 
** This subroutine will read the image data from a TIFF file containing an
** arbitrary number of samples. Image data can contain 8 or 16 bits.
*/

static mxArray *
ReadNSampleImage(TIFF *tif)
{
    uint8_T   **ptrSamples8 ;
    uint16_T  **ptrSamples16 ;
    mxArray *outArray;
    uint32_T i,j,row,col,k;
    uint16 bps,spp,config,sampleFormat; 
    uint32 imageWidth,imageHeight;         /* image width, height */
    int dims[3];         /* For the calls to mxCreateNumericArray */
    unsigned int scanlineSize;
    uint8_T *buf_8;
    uint16_T *buf_16;
    
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH,  &imageWidth);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imageHeight);
    TIFFGetFieldDefaulted(tif, TIFFTAG_SAMPLESPERPIXEL, &spp);
    TIFFGetFieldDefaulted(tif, TIFFTAG_BITSPERSAMPLE, &bps);
    TIFFGetField(tif, TIFFTAG_PLANARCONFIG, &config);
    TIFFGetField(tif, TIFFTAG_SAMPLEFORMAT, &sampleFormat);

    dims[0]  = imageHeight;                /* Image Height */
    dims[1]  = imageWidth;                 /* Image Width  */
    dims[2]  = spp;                        /* Color planes */
      
    if(TIFFIsTiled(tif)) {
        TIFFClose(tif);
        mexErrMsgTxt("Tiled TIFF images are not supported");
    }

    /* Image is organized in strips */
    scanlineSize = TIFFScanlineSize(tif);
      
    
      
    if (bps==8) {
    
        outArray = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
 
        /* Create array of pointers for each sample in the image. */
        ptrSamples8 = (uint8_T **) mxMalloc(spp*sizeof(uint8_T *));
        *ptrSamples8 = (uint8_T *) mxGetData(outArray);

        for(j = 1; j < spp; j++)
        {
            *(ptrSamples8+j) = *ptrSamples8 + (j*imageHeight*imageWidth);
        }
        
                   
    } else if (bps==16) {
    
        outArray = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL); 
        
        /* Create array of pointers for each sample in the image. */
        ptrSamples16 = (uint16_T **) mxMalloc(spp*sizeof(uint16_T *));
        *ptrSamples16 = (uint16_T *) mxGetData(outArray);
        
        for(j = 1; j < spp; j++)
        {
            *(ptrSamples16+j) = *ptrSamples16 + (j*imageHeight*imageWidth);
        }
        
    } else {
        TIFFClose(tif);
        mexErrMsgTxt("Unsupported bit-depth for TIFF image file.");
    }

         
    if(config==PLANARCONFIG_CONTIG)   {

        /* Chunky mode - RGBRGBRGB... */

        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_8, row, 0) == -1)
                    CloseAndError(tif);
                
                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    for(k = 0; k < spp; k++)
                    {
                        *(*(ptrSamples8+k)+j)  = buf_8[col*spp+k];;
                    }
                }
            }          
            mxFree(buf_8);
            mxFree(ptrSamples8);
            
        } else if (bps==16) {
            
            buf_16 = (uint16_T *) mxCalloc(scanlineSize, sizeof(uint16_T));
            
            for (row = 0; row < imageHeight; row++)
            {
                if (TIFFReadScanline(tif, buf_16, row, 0) == -1)
                    CloseAndError(tif);
                
                for (col = 0; col < imageWidth; col++)
                {
                    j = row + (col * imageHeight);
                    for(k = 0; k < spp; k++)
                    {
                        *(*(ptrSamples16+k)+j)  = buf_16[col*spp+k];;
                    } 
                }
            }          
            mxFree(buf_16);
            mxFree(ptrSamples16);
        }   

    } else if(config == PLANARCONFIG_SEPARATE)   {

        /* Planar format - RRRRRR...  GGGGG... BBBBB.... */
        
        if (bps==8) {
            buf_8 = (uint8_T *) mxCalloc(scanlineSize,sizeof(uint8_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_8, row, (uint8_T) i) == -1)
                        CloseAndError(tif);
                    
                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        
                        *(*(ptrSamples8+i)+j) = buf_8[col];
                        
                    }
                }   
            mxFree(buf_8);
            mxFree(ptrSamples8);
        }
        else if (bps==16) {
            buf_16 = (uint16_T *) mxCalloc(scanlineSize,sizeof(uint16_T));
            
            for (i = 0; i < (int) spp; i++) /* Loop over image planes */
                for (row = 0; row < imageHeight; row++)
                {
                    if (TIFFReadScanline(tif, buf_16, row, (uint16_T) i) == -1)
                        CloseAndError(tif);
                    
                    for (col = 0; col < imageWidth; col++)
                    {
                        j = row + (col * imageHeight);
                        
                        *(*(ptrSamples16+i)+j) = buf_16[col];
                        
                    }
                }   
            mxFree(buf_16);
            mxFree(ptrSamples16);
        }
    }

    return outArray;

}



static void
StuffContigTileBufferIntoRGB(TIFF *tif,
                             uint8_T *buf,
                             int tileCol,
                             int tileRow,
                             uint8_T *ptrRed,
                             uint8_T *ptrGreen,
                             uint8_T *ptrBlue)
{
    int cols, rows, twid, tlen;
    int i,j, matrixIdx;
    
  /* TIFFGetField only errors if asked for a field which doesn't exist in
   * the spec.  Consequently, we needn't wrap calls to it in error-handling
   * routines. */
    TIFFGetField(tif, TIFFTAG_TILEWIDTH, &twid);
    TIFFGetField(tif, TIFFTAG_TILELENGTH, &tlen);
    TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &cols);
    TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &rows);

    for(i=0; i<tileRow; i++)
        for(j=0; j<tileCol; j+=3)
        {
            matrixIdx = (i+tileRow*tlen) + (rows*(j+tileCol*twid));
            ptrRed[matrixIdx] = buf[j + i*twid];
            ptrGreen[matrixIdx] = buf[j+1 + i*twid];
            ptrBlue[matrixIdx] = buf[j+2 + i*twid];
        }
}



/*******************************************/
static void ErrHandler(const char *module, 
                       const char *fmt, va_list ap)
{

  char *cp;
  char *buf;

  buf = cp = (char *) mxMalloc(2048 * sizeof(char));

  if (module != NULL) {
    sprintf(cp, "%s: ", module);
    cp = (char *) strchr(cp, '\0');
  }

  vsprintf(cp, fmt, ap);
  strcat(cp, ".");

  ERROR_BUFFER = buf;
}


/*******************************************/
static void CloseAndError(TIFF *tif)
{
    TIFFClose(tif);
    mexErrMsgTxt(ERROR_BUFFER);
}


/*******************************************/
static void WarnHandler(const char *module, 
                       const char *fmt, va_list ap)
{
    /* ignore libtiff warnings */
}


/*******************************************/
static mxArray *
GetColormap(TIFF* tif, uint16_T bps)
{
    int cmdims[2];
    mxArray *colormap;
    uint16_T *red_colormap, *green_colormap, *blue_colormap;  
    uint16_T *ptrCmRed, *ptrCmGreen, *ptrCmBlue; /* Colormap arrays */
    int pixmax,i;             /* Maximum allowable pixel value (1<<bps)-1 */

    pixmax = (1<<bps)-1;          /* Maximum allowable pixel value with */

    if(TIFFGetField(tif, TIFFTAG_COLORMAP, &red_colormap,
                    &green_colormap, &blue_colormap))
    {                         /* We know it's an indexed image */
        cmdims[0] = 1<<bps;   /* Length of colormap */
        cmdims[1] = 3;        /* 3 colors */
        colormap = mxCreateNumericArray(2, cmdims, mxUINT16_CLASS, mxREAL);
        ptrCmRed   = (uint16_T *) mxGetData(colormap);
        ptrCmGreen = &ptrCmRed[pixmax+1];
        ptrCmBlue  = &ptrCmGreen[pixmax+1];
        
        for(i=0; i<cmdims[0]; i++)
        {
            ptrCmRed[i]   = red_colormap[i];
            ptrCmGreen[i] = green_colormap[i];
            ptrCmBlue[i]  = blue_colormap[i];
        }      
    }
    
    else
    {
        mexWarnMsgTxt("TIFF file contains indexed image without colormap.");
        colormap = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
    return colormap;
}
