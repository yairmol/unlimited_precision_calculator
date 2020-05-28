#include <stdio.h> 
#include <stdlib.h> 
#include <time.h> 
  
// Generates and prints 'count' random 
// numbers in range [lower, upper]. 
char digits[16];
void generate_number(int count, char* buffer) 
{ 
    int lower = 0, upper = 15;
    int i;
    buffer[0] =  digits[(rand() % (upper - lower + 2)) + lower + 1];
    for (i = 1; i < count; i++) { 
        char num = digits[(rand() % (upper - lower + 1)) + lower]; 
        buffer[i] = num;
    }
    buffer[count] = '\n';
    buffer[count+1] = '\0'; 
}

void generate_action(char* buffer, char* actions) 
{ 
    int lower = 0, upper = 3;
    char action = actions[(rand() % (upper - lower + 1)) + lower]; 
    buffer[0] = action;
    buffer[1] = '\n';
    buffer[2] = '\0'; 
} 
  
// Driver code 
int main() 
{
    if (1){
        char buffer [280];
        char* plus = "+\n";
        char* dup = "d\n";
        char* pop = "p\n";
        char* num = "n\n";
        char* quit = "q\n";
        FILE* input = fopen("input1.txt", "w");
        int i, j;
        for (j = 0; j < 278; j++){
            buffer[j] = 'F';
        }
        buffer[278] = '\n';
        for (i = 0; i < 2; i++){
            fwrite(buffer, 1, 279, input);
            if (i >= 1){
                fwrite(plus, 1, 2, input);
                fwrite(dup, 1, 2, input);
                fwrite(pop, 1, 2, input);
            } 
        }
        fwrite(num, 1, 2, input);
        fwrite(pop, 1, 2, input);
        fwrite(quit, 1, 2, input);
    } else {
    int i;
    int count = 20; 
    FILE* input = fopen("random_input.txt", "w");
    char buffer[80];
    char actions[] = {'+', '&', '|', 'n'};
    if (input == NULL){
        exit(1);
    }
    srand(time(0));
    for (i = 0; i < 16; i++){
        digits[i] = i + 48;
        if (i >= 10){
            digits[i] = i + 55;
        }
    }
    for (i = 0; i < 5; i++){ 
        count = (rand() % (80 - 1 + 1)) + 1; 
        // Use current time as  
        // seed for random generator 
        generate_number(count, buffer);
        fwrite(buffer, 1, count+1, input); 
    }
    for (i = 0; i < 5; i++)
    {
        generate_action(buffer, actions);
        fwrite(buffer, 1, 2, input);
        buffer[0] = 'd';
        buffer[1] = '\n';
        fwrite(buffer, 1, 2, input);
        buffer[0] = 'p';
        buffer[1] = '\n';
        fwrite(buffer, 1, 2, input);
    }
    buffer[0] = 'q';
    buffer[1] = '\n';
    fwrite(buffer, 1, 2, input);
    fclose(input);
    }
    
    return 0; 
} 