%{

#include <stdlib.h>
#include "yacc.tab.h"

%}

DIGIT	[0-9]
ID		[a-z][a-z0-9]*

%%

{ID}					{ return (ID); }
{DIGIT}+				{ return (int);  }
{DIGIT}+"."{DIGIT}*		{ return (float); }
mainprog | function | procedure | begin | end | if | then | else | nop | while | return | print | in	{return (keyword); }
"+" | "-" | "*" | "/" | "<" | "<=" | ">=" | ">" | "==" | "!=" | "!"		{ return (Operator); }
";" | "." | "," | "=" | "()" | ")" | "[" | "]" | ":"	{return (Delimiter); }
[ \t\n]+ ; //whitespace를 무시한다.
"{"[^}\n]*"}"  // {}안의 내용은 주석처리한다.
.                     { yyerror();  }

%%

int main(void)
{
   yyparse();
   return 0;
}

int yywrap(void)
{
   return 0;
}

int yyerror(void)
{
    printf("Error\n");
    exit(1);
}