%{
#include <stdlib.h>
#include "yacc.tab.h" /* token codes from the parser */
int line = 1;
int statement_line = 1;
%}

%%

 /*키워드로 시작하는 ID*/
mainprog[a-zA-Z0-9]+	{ strcpy(yylval.sval,yytext); return (ID); }
function[a-zA-Z0-9]+	{ strcpy(yylval.sval,yytext); return (ID); }
procedure[a-zA-Z0-9]+	{ strcpy(yylval.sval,yytext); return (ID); }
begin[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
end[a-zA-Z0-9]+			{ strcpy(yylval.sval,yytext); return (ID); }
if[a-zA-Z0-9]+			{ strcpy(yylval.sval,yytext); return (ID); }
then[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
else[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
nop[a-zA-Z0-9]+			{ strcpy(yylval.sval,yytext); return (ID); }
while[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
return[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
print[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
in[a-su-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
for[a-zA-Z0-9]+			{ strcpy(yylval.sval,yytext); return (ID); }
elif[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }
int[a-zA-Z0-9]+			{ strcpy(yylval.sval,yytext); return (ID); }
float[a-zA-Z0-9]+		{ strcpy(yylval.sval,yytext); return (ID); }

 /*키워드*/
mainprog	{ statement_line = line; strcpy(yylval.sval,yytext); return (MAINPROG);}
function	{ statement_line = line; strcpy(yylval.sval,yytext); return (FUNCTION);} 
procedure	{ statement_line = line; strcpy(yylval.sval,yytext); return (PROCEDURE);}
begin		{ statement_line = line; strcpy(yylval.sval,yytext); return (_BEGIN);}
end			{ strcpy(yylval.sval,yytext); return (_END);}
if			{ statement_line = line; strcpy(yylval.sval,yytext); return (IF);} 
then		{ statement_line = line; strcpy(yylval.sval,yytext); return (THEN);} 
else		{ statement_line = line; strcpy(yylval.sval,yytext); return (ELSE);}
nop			{ statement_line = line; strcpy(yylval.sval,yytext); return (NOP);}
while		{ statement_line = line; strcpy(yylval.sval,yytext); return (WHILE);} 
return		{ statement_line = line; strcpy(yylval.sval,yytext); return (RETURN);}
print		{ statement_line = line; strcpy(yylval.sval,yytext); return (PRINT);}
for			{ statement_line = line; strcpy(yylval.sval,yytext); return (FOR);}
elif		{ statement_line = line; strcpy(yylval.sval,yytext); return (ELIF);}
in			{ statement_line = line; strcpy(yylval.sval,yytext); return (IN);}
int			{ strcpy(yylval.sval,yytext); return (TYPE); }
float		{ strcpy(yylval.sval,yytext); return (TYPE); }

"+"			{strcpy(yylval.sval,yytext); return (PLUS);} 
"-"			{strcpy(yylval.sval,yytext); return (MINUS);}
"*"			{strcpy(yylval.sval,yytext); return (MUL);} 
"/"			{strcpy(yylval.sval,yytext); return (DIV);} 
"<"			{strcpy(yylval.sval,yytext); return (LESS);} 
">"			{strcpy(yylval.sval,yytext); return (GREATER);} 
"=="		{strcpy(yylval.sval,yytext); return (EQUAL);} 
"<="		{strcpy(yylval.sval,yytext); return (EQLESS);} 
">="		{strcpy(yylval.sval,yytext); return (EQGREATER);} 
"!="		{strcpy(yylval.sval,yytext); return (NEQUAL);}
"!"			{strcpy(yylval.sval,yytext); return (NOT);}
"="			{strcpy(yylval.sval,yytext); return (ASSIGNMENT);}

";"			{
				strcpy(yylval.sval,yytext); 
				return (SEMICOLON);
			}
":"			{strcpy(yylval.sval,yytext); return (COLON);}
"."			{strcpy(yylval.sval,yytext); return (DOT);}
","			{strcpy(yylval.sval,yytext); return (COMMA);}
"("			{strcpy(yylval.sval,yytext); return (LP);} 
")"			{strcpy(yylval.sval,yytext); return (RP);} 
"["			{strcpy(yylval.sval,yytext); return (LB);}
"]"			{strcpy(yylval.sval,yytext); return (RB);}

 /*ID*/
[a-zA-Z][a-zA-Z0-9]*			{ 
									strcpy(yylval.sval,yytext);
									return (ID); 
								}
 /*잘못된 ID*/
[0-9][.]*[0-9a-zA-Z]*[a-zA-Z]+	{
									char buffer[256];
									sprintf(buffer,"lexical error, unrecognized token \"%s\"", yytext);
									yyerror(buffer); 
								}

[0-9]+"."[0-9]+					{
									yylval.dval = atof(yytext);
									return (FLOAT);
								}
[0-9]+							{
									yylval.dval = atoi(yytext);
									return (INT);
								}

\n 				{ line++; }
[ \t]+			/* whitespace를 무시한다.*/
"//"[^\n]*		/* //뒤의 내용은 주석처리한다.*/
.               { 
					char buffer[256];
					sprintf(buffer,"lexical error, unexpected character \"%c\"", yytext[0]);
					yyerror(buffer); 
				}

%%
