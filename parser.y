%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

extern int yylex();
extern int yyparse();
extern int yylineno;

void yyerror(const char* s);
int isVarDeclared(const char* name);
void addNewVar(const char* name, int capacity);
void checkMoveVarCapacity(char* var1, char* var2);
void checkMoveIntCapacity(int var1, char* var2);
void checkAddIntCapacity(int var1, char* var2);
void checkAddVarCapacity(char* var1, char* var2);
int getVarIndex(char *varName);
int getIntegerLength(int number);


struct variable {
    char* name;
    int capacity;
    int variable_value;
};

int numVars = 0;
struct variable vars[100];
bool isValidProgram = true;

%}

%token BEGINING BODY END MOVE ADD TO INPUT STRING
%token PRINT FULLSTOP SEMICOLON
%token <capacity>VAR_DECLAR 
%token <name>VAR_ID
%token <integer_value>INTEGER
%union {
    int capacity;
    char *name;
    int integer_value;
    int variable_value;
}

%%

program : begining_section body_section END {
    if (isValidProgram) {
        printf("Program is valid.\n");
    }
    else {
        printf("Program is invalid.\n");
    }
    exit(0);
}
    ;

begining_section : BEGINING | BEGINING var_declarations
    ;

var_declarations :  var_declarations VAR_DECLAR VAR_ID FULLSTOP { 
                        if (isVarDeclared($3)) {
                            printf("Error: Variable %s is already declared. lineno - (%d)\n", $3, yylineno);
                            
                        } else {
                            addNewVar($3, $2); 
                        }
                    }
                    | VAR_DECLAR VAR_ID FULLSTOP { 
                        if (isVarDeclared($2)) {
                            printf("Error: Variable %s is already declared. lineno - (%d)\n", $2, yylineno);
                            
                        } else {
                            addNewVar($2, $1); 
                        }
                    }
    ;

body_section : BODY statements
    ;

statements : statements statement | statement
    ;

statement : input_statement | print_statement | move_statement | add_statement
    ;   

input_statement : INPUT VAR_ID FULLSTOP
    ;

print_statement : PRINT print_expression
    ;

print_expression : VAR_ID SEMICOLON print_expression | STRING SEMICOLON print_expression | VAR_ID FULLSTOP | STRING FULLSTOP
    ;

move_statement : MOVE VAR_ID TO VAR_ID FULLSTOP {checkMoveVarCapacity($2, $4);}
                | MOVE INTEGER TO VAR_ID FULLSTOP {checkMoveIntCapacity($2, $4);}
    ;

add_statement : ADD VAR_ID TO VAR_ID FULLSTOP {checkAddVarCapacity($2, $4);}
                | ADD INTEGER TO VAR_ID FULLSTOP {checkAddIntCapacity($2, $4);}
    ;

%%

int main(){
    while(1) {
        printf("Insert Bucol Program\n");
        yyparse();
    }   
}

// Add new variable with it's capacity to the list of variables
void addNewVar(const char* name, int capacity) {
    vars[numVars].name = strdup(name);
    vars[numVars].capacity = capacity;
    numVars++;
}

// Check if the variable is declared
int isVarDeclared(const char* name) {
    for (int i = 0; i < numVars; i++) {
        if (strcmp(vars[i].name, name) == 0) {
            return 1;
        }
    }
    return 0;
}

void yyerror(const char *s) {
    printf("\nProgram is invalid.\n");
    fprintf(stderr, "Error one line %s\n",  s);
}

// Check the capacity of the variable can hold the integer
void checkMoveIntCapacity(int var1, char* var2) {
    int i = getVarIndex(var2);
    // Check if the variable is declared
    if (isVarDeclared(var2)) {
        // Check the variable can hold the integer
        if (getIntegerLength(var1) > vars[i].capacity) {
            printf("Error: Variable %s has insufficient capacity for this operation. lineno - (%d)\n", var2, yylineno);
            isValidProgram = false;
        } else {
            vars[i].variable_value = var1;
        }
    } else {
        printf("Error: Variable %s is not declared. lineno - (%d)\n", var2, yylineno);
        isValidProgram = false;
    }
}

// Check the value of varMovedFrom fits into the capacity of varMovedInto
void checkMoveVarCapacity(char* varMovedFrom, char* varMovedInto) {
    // Check if the variables are declared
    if(isVarDeclared(varMovedFrom) && isVarDeclared(varMovedInto)){
        int i = getVarIndex(varMovedFrom);
        int j = getVarIndex(varMovedInto);
        if(vars[i].variable_value) {
            if (getIntegerLength(vars[i].variable_value) > vars[j].capacity) {
                printf("Error: Variable %s has insufficient capacity for this operation. lineno - (%d)\n", varMovedInto, yylineno);
                isValidProgram = false;
            } else {
                vars[j].variable_value = vars[i].variable_value;
            }
        } else {
            printf("Error: Variable %s has no initial value. Cannot move a null value.\n", varMovedFrom);
            isValidProgram = false;
        }
    } else {
        isValidProgram = false;
        printf("Error: Variable %s or %s is not declared. lineno - (%d)\n", varMovedFrom, varMovedInto, yylineno);
    }
}

// Check the capacity of the variable can hold the new value after adding the integer to the existing value
void checkAddIntCapacity(int var1, char* var2) {
    int i = getVarIndex(var2);
    if (isVarDeclared(var2)) {
        if (vars[i].variable_value) {
            if (getIntegerLength(vars[i].variable_value + var1) > vars[i].capacity) {
                isValidProgram = false;
                printf("Error: Variable %s has insufficient capacity for this operation. lineno - (%d)\n", var2, yylineno);
            } else {
                vars[i].variable_value += var1;
            }
        } else {
            isValidProgram = false;
            printf("Error: Variable %s has no inital value. Cannot add to a null value. \n", var2);
        }
    } else {
        isValidProgram = false;
        printf("Error: Variable %s is not declared. lineno - (%d)\n", var2, yylineno);
    }
}

// Check the capacity of the variable can hold the new value after adding the value of var1 to the value of var2
void checkAddVarCapacity(char* var1, char* var2) {
    int i = getVarIndex(var1);
    int j = getVarIndex(var2);
    if(isVarDeclared(var1) && isVarDeclared(var2)) {
        if (vars[i].variable_value && vars[j].variable_value) {
            if (getIntegerLength(vars[i].variable_value + vars[j].variable_value) > vars[j].capacity) {
                isValidProgram = false;
                printf("Error: Variable %s has insufficient capacity for this operation. lineno - (%d)\n", var2, yylineno);
            } else {
                vars[j].variable_value += vars[i].variable_value;
            }
        } else {
            isValidProgram = false;
            printf("Error: Variable %s or %s has no inital value. Cannot add to a null value. lineno - (%d)\n", var1, var2, yylineno);
        }
    } else {
        isValidProgram = false;
        printf("Error: Variable %s or %s is not declared. lineno - (%d)\n", var1, var2, yylineno);
    }
}

int getVarIndex(char *varName) {
    for(int i = 0; i < numVars; i++) {
        if(strcmp(vars[i].name, varName)==0) { 
            return i;
        }
    }
}

// gets the number of digits in an integer
int getIntegerLength(int number) {
    int length = 0;
    if (number < 0) {
        length = 1;
        number *= -1;
    }
    do {
        length++;
        number /= 10;
    } while (number != 0);
    return length;
}
