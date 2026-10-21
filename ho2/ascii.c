#include <stdio.h>
int main()
{
    int i,j;
    char word='a';
    for(i=0;i<2;i++)
    {
        for(j=0;j<13;j++)
        {
            printf("%c ",word);
            word++;
        }
        printf("\n");
    }
    return 0;
}