#!/bin/bash
# test_c.sh — test C toolchain and GSL inside the container

set -e

echo "[ GCC ]"
gcc --version | head -1
echo "✓ GCC OK"

echo ""
echo "[ GSL ]"
gsl-config --version
echo "✓ GSL OK"

echo ""
echo "[ GSL compile ]"
cat > /tmp/test_gsl.c << 'CSRC'
#include <stdio.h>
#include <gsl/gsl_math.h>
int main() {
    printf("GSL pi = %.10f\n", M_PI);
    return 0;
}
CSRC
gcc /tmp/test_gsl.c -o /tmp/test_gsl $(gsl-config --cflags --libs)
/tmp/test_gsl
echo "✓ GSL compile and run OK"

echo ""
echo "[ gnuplot ]"
gnuplot --version
echo "✓ gnuplot OK"

echo ""
echo "[ epstopdf ]"
epstopdf --version
echo "✓ epstopdf OK"
