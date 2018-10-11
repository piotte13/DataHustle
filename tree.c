#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int predict(float features[3]) {

    int classes[3];
        
    if (features[2] <= 56425.5) {
        classes[0] = 2525; 
        classes[1] = 10364; 
        classes[2] = 16961; 
    } else {
        classes[0] = 1; 
        classes[1] = 8337; 
        classes[2] = 1413; 
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