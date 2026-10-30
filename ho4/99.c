#include <stdio.h>

void print_equation(int i, int j); 

int main()
 {
    int i, j;

    printf("The 9mul9 table:\n");
    for (i = 9; i >= 1; i--)
     {
        for (j = 1; j <= i; j++)
         {
            print_equation(i, j);
            printf("  "); 
        }
        printf("\n");
    }

    return 0;
}

void print_equation(int i, int j)
 {

    printf("%d*%d=%d", i, j, i * j);
}