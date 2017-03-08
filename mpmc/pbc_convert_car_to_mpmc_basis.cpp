#include <iostream>
#include <string>
#include <strings.h>
#include <sstream>
#include <algorithm>
#include <iterator>
#include <fstream>
#include <stdio.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include <map>
#include <string>
#include <vector>
#include <stdlib.h>
#include <time.h>
#include <chrono>

using namespace std;

int main(int argc, char **argv) {

/*
use, e.g.

g++ pbc_convert_car_to_mpmc_basis.cpp -lm -o car2mpmc -I. -std=c++11

to (re-)compile.

[ requires C++11 compiler ]
e.g. 
module load  compilers/gcc/6.2.0     <-- on circe
module load gcc/4.9.3                <-- on stampede
*/

    if (argc != 7) {
        printf("Only %i arguments provided.\n",argc-1);
        cout << "You need to supply a b c alpha beta gamma IN THAT ORDER\n";
        cout << "e.g.\n";
        cout << "./executable 25.669 25.669 24.123 90 90 120\n";
        return 0;
    }

    double A = atof(argv[1]);
    double B = atof(argv[2]);
    double C = atof(argv[3]);

    double alpha = atof(argv[4]);
    double beta = atof(argv[5]);
    double gamma = atof(argv[6]);

    printf("\"Works every time\" PBC data conversion. Space group 2017.\n");

    printf("Inputs:\n");
    printf("a =     %8.5f\n",A);
    printf("b =     %8.5f\n",B);
    printf("c =     %8.5f\n",C);
    printf("alpha = %8.5f\n",alpha);
    printf("beta  = %8.5f\n",beta);
    printf("gamma = %8.5f\n",gamma);

    printf("\n\ncalculating MPMC input style basis vectors...\n\n");

    // before transposing: http://lammps.sandia.gov/doc/Section_howto.html#triclinic-non-orthogonal-simulation-boxes
    vector<double> basis0(3), basis1(3), basis2(3);    

    basis0[0] = A;    // a_x
    basis0[1] = B*cos(M_PI/180.0 * gamma);  // b_x
    basis0[2] = C*cos(M_PI/180.0 * beta); // c_x

    basis1[0] = 0;   // 0
    basis1[1] = B*sin(M_PI/180.0 * gamma); // b_y
    basis1[2] = ((0*0 + B*0 + 0*C) - (basis0[1]*basis0[2]))/basis1[1]; // c_y
    
    basis2[0] = 0;
    basis2[1] = 0;
    basis2[2] = sqrt(C*C - basis0[2]*basis0[2] - basis1[2]*basis1[2]); // c_z


    /* I'm just printing it transposed instead of changing vector values. same result. This should work for any system.. */
    printf("===================================\n\n");

    printf("basis1   %8.5f %8.5f %8.5f\n", basis0[0], basis1[0], basis2[0]);
    printf("basis2   %8.5f %8.5f %8.5f\n", basis0[1], basis1[1], basis2[1]);
    printf("basis3   %8.5f %8.5f %8.5f\n", basis0[2], basis1[2], basis2[2]);

    printf("\n===================================\n\n");

    printf("See http://lammps.sandia.gov/doc/Section_howto.html#triclinic-non-orthogonal-simulation-boxes    for details. LAMMPS uses the transposed version of ours.\n");

    printf("Love, the space group.\n");


    /* tests worked for:
    MPM-1-Br     (hexagonal)
    MOF-5        (cubic)
    Mn-Formate   (something weird)

    
    */
    return 0;
}
