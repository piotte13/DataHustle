#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int predict(float features[3]) {

    int classes[3];
        
    if (features[2] <= 56425.5) {
        classes[0] = 2771; 
        classes[1] = 7113; 
        classes[2] = 19966; 
    } else {
        classes[0] = 11; 
        classes[1] = 7639; 
        classes[2] = 2101; 
    }

    int index = 0;
    for (int i = 0; i < 3; i++) {
        index = classes[i] > classes[index] ? i : index;
    }
    return index;
}

int main(int argc, const char * argv[]) {

    /* Features: */
    double features[argc-1];
    int i;
    for (i = 1; i < argc; i++) {
        features[i-1] = atof(argv[i]);
    }

    /* Prediction: */
    printf("%d", predict(features));
    return 0;

}