/*
    // reads an .stl file and writes out the .xyz coordinates of the triangles
    
    // compile with
    // g++ stl_to_xyz.cpp -std=c++11 -o ./go

    // run with
    // ./go
*/



#include <stdio.h>
#include <cstdlib>

using namespace std;

int main(int argc, char **argv) {

    // your .stl file name
    const char* filename = "Copy_of_Koenigsegg_CCR_model.stl";

    FILE *fileptr, *outfile;
    char *header; 
    unsigned int ntri = 0;   
    header = (char *)calloc( sizeof(char), 80+1 );
    
    fileptr = fopen(filename, "rb");
    outfile = fopen("out.xyz", "w");

    fseek( fileptr, 0, SEEK_SET) ;
    fread( header, 1, sizeof(char)*80, fileptr );
    printf("header:\n%s\n", header);

    fseek( fileptr, 80, SEEK_SET);
    fread( &ntri, 1, sizeof( unsigned int ), fileptr );
    printf("ntri: %i\n", ntri);

    for (int i=0; i< ntri; i++) {
        printf(" DATA FOR TRIANGLE %i\n", i);
        float n[3] = {0,0,0}; 
        float v1[3] = {0,0,0}; 
        float v2[3] = {0,0,0};
        float v3[3] = {0,0,0}; 
        unsigned short int attr = 0;
        fread( &n, 3, sizeof(float), fileptr);
        fread( &v1, 3, sizeof(float), fileptr);
        fread( &v2, 3, sizeof(float), fileptr);
        fread( &v3, 3, sizeof(float), fileptr);
        fread( &attr, 1, sizeof(unsigned short int), fileptr);

        /*
            printf("norm: %f %f %f\n", n[0], n[1], n[2]);
            printf("v1: %f %f %f\n", v1[0],v1[1],v1[2]);
            printf("v2: %f %f %f\n", v2[0],v2[1],v2[2]);
            printf("v3: %f %f %f\n", v3[0],v3[1],v3[2]);
            printf("attr: %hi\n", attr);   
        */

        fprintf(outfile, "%f %f %f\n", v1[0],v1[1],v1[2]);
        fprintf(outfile, "%f %f %f\n", v2[0],v2[1],v2[2]);
        fprintf(outfile, "%f %f %f\n", v3[0],v3[1],v3[2]);

    }
    fclose( fileptr );
    fclose( outfile );
    return 0;

} // end main()
