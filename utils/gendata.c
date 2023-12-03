#include <stdio.h>
#include <stdlib.h>

#ifndef MAX_ITERS
#define MAX_ITERS 5E5
#endif
#define ROWS 3

int main() {
  int i, j;
  srand(1);
  FILE *fptr = fopen("gendata-csv", "w");
  for (i = 0; i < ROWS; i++) {
    for (j = 0; j < MAX_ITERS - 1; j++) {
      fprintf(fptr, "%f,", (double)rand() / RAND_MAX);
    }
    fprintf(fptr, "%f", (double)rand() / RAND_MAX);
    fprintf(fptr, "\n");
  }
  fclose(fptr);
  return 0;
}
