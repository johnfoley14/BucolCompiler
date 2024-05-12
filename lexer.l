%{
    /* Definitions (c code for includes and declarations) */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "parser2.tab.h"

%}

%option caseless
%option yylineno
/* rules for the lexer */
%%

[\t ]+			/* Ignore whitespace */ ;
[\n]+			/* Ignore whitespace */ ;
"BEGINING."		{ return BEGINING; }
"BODY."			{ return BODY; }
"END."			{ return END; }
"MOVE"			{ return MOVE; }
"ADD"			{ return ADD; }
"TO"			{ return TO; }
"INPUT"			{ return INPUT; }
"PRINT"			{ return PRINT; }
[Xx]+           { yylval.capacity = strlen(yytext); return VAR_DECLAR; }  
[A-Za-z][A-Za-z0-9\-]* { yylval.name = strdup(yytext); return VAR_ID; }
(-)?[0-9]+      { yylval.integer_value = atoi(yytext); return INTEGER; }
\"(\\.|[^"\\])*\" { return STRING; }
"."             { return FULLSTOP; }
";"             { return SEMICOLON; }


%%

int yywrap(void){
    return 1;
}
