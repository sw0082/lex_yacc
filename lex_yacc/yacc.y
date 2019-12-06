%{
 /*
  A lexer for basic grammar to use for recognizing english sentences.
  */

#define YYERROR_VERBOSE

#include <stdio.h>
extern FILE *yyin;
extern int line;
extern int statement_line;

void push_symbol_table(char* scope);
void pop_symbol_table();
int add_symbol(char* name);
int lookup_symbol(char* name);
%}

%union {
	int		ival;
	double	dval;
	char	sval[256];
}

%token <sval> ID
%token <sval> ASSIGNMENT
%token <sval> PLUS MINUS MUL DIV 
%token <sval> LESS GREATER EQUAL EQLESS EQGREATER NEQUAL NOT LP RP LB RB
%token <sval> TYPE
%token <sval> MAINPROG FUNCTION PROCEDURE _BEGIN _END
%token <sval> IF THEN ELSE NOP FOR ELIF
%token <sval> WHILE RETURN PRINT IN
%token <sval> SEMICOLON COLON DOT COMMA

%token <ival> INT
%token <dval> FLOAT

%left OR
%left AND
%left NOT
%left COMPARE
%left PLUS
%left MINUS
%left MUL 
%left DIV
%right ASSIGNMENT
%nonassoc UMINUS

%type <sval> relop
%%

program :
	MAINPROG mainprogram_name SEMICOLON declarations subprogram_declarations compound_statement { pop_symbol_table() }
	;
mainprogram_name:
	ID { push_symbol_table($1); }
	;
declarations:
	/*epsilon*/
	| type identifier_list SEMICOLON declarations subprogram_declarations { }
	;
identifier_list:
	ID							{
									if(add_symbol($1) == 0)
									{
										char buffer[256];
										sprintf(buffer,"semantic error, duplicate symbol \"%s\"",$1);
										yyerror(buffer);
									}
								}
	| ID COMMA identifier_list	{
									if(add_symbol($1) == 0)
									{
										char buffer[256];
										sprintf(buffer,"semantic error, duplicate symbol \"%s\"",$1);
										yyerror(buffer);
									}
								}
	;
type:
	TYPE 
	| TYPE LB INT RB
	;
subprogram_declarations:
	/*epsilon*/
	| subprogram_declaration subprogram_declarations
	;
subprogram_declaration:
	subprogram_head declarations compound_statement {pop_symbol_table()}
	;
subprogram_head: 
	FUNCTION function_name arguments COLON TYPE SEMICOLON	
	| PROCEDURE procedure_name arguments SEMICOLON			
	;
function_name:
	ID	{
			if(add_symbol($1) == 0)
			{
				char buffer[256];
				sprintf(buffer,"semantic error, duplicate symbol \"%s\"",$1);
				yyerror(buffer);
			}
			push_symbol_table($1); 
		}
	;
procedure_name:
	ID	{ 
			if(add_symbol($1) == 0)
			{
				char buffer[256];
				sprintf(buffer,"semantic error, duplicate symbol \"%s\"",$1);
				yyerror(buffer);
			}
			push_symbol_table($1); 
		}
	;
arguments:
	/*epsilon*/
	| LP parameter_list RP
	;
parameter_list: 
	identifier_list COLON type | identifier_list COLON type SEMICOLON parameter_list
	;
compound_statement:
	_BEGIN statement_list _END
	;
statement_list:
	statement | statement SEMICOLON statement_list
	;
statement: 
	variable ASSIGNMENT expression 
	| print_statement
	| procedure_statement 
	| compound_statement 
	| if_statement 
	| while_statement
	| for_statement 
	| RETURN expression 
	| NOP
	;
if_statement: 
	IF expression COLON statement elif_statement else_expression
	;
elif_statement:	
	/*epsilon*/
	| ELIF expression COLON statement elif_statement
	;
else_expression:
	/*epsilon*/
	| ELSE COLON expression
	;
while_statement: 
	WHILE expression COLON statement else_statement
	;
for_statement: 
	FOR simple_expression relop simple_expression COLON statement else_statement
	{
		if(strcmp($3,"in")!=0)
			statement_error("syntax error, \"in\" is missing before \":\"");
	}
	| FOR simple_expression relop simple_expression relop simple_expression COLON statement else_statement	
	{
		if(strcmp($3,"in")!=0 && strcmp($5,"in")!=0)
			statement_error("syntax error, \"in\" is missing before \":\"");
	}
	| FOR simple_expression relop simple_expression relop simple_expression relop simple_expression COLON statement else_statement	
	{
		if(strcmp($5,"in")!=0)
		{
			char buffer[256];
			sprintf(buffer,"syntax error, unexpected \"%s\", expecting \"in\"",$5);
			statement_error(buffer);
		}
	}
	;
else_statement:
	/*epsilon*/
	| ELSE COLON statement
	;
print_statement: 
	PRINT 
	| PRINT LP expression RP
	;
variable: 
	ID						{
								if(lookup_symbol($1) == 0)
								{
									char buffer[256];
									sprintf(buffer,"semantic error, undefined symbol \"%s\"",$1);
									yyerror(buffer);
								}
							}
	| ID LB expression RB	{
								if(lookup_symbol($1) == 0)
								{
									char buffer[256];
									sprintf(buffer,"semantic error, undefined symbol \"%s\"",$1);
									yyerror(buffer);
								}
							}
	;
procedure_statement:
	ID LP actual_parameter_expression RP	{
												if(lookup_symbol($1) == 0)
												{
													char buffer[256];
													sprintf(buffer,"semantic error, undefined symbol \"%s\"",$1);
													yyerror(buffer);
												}
											}
	;
actual_parameter_expression: 
	/*epsilon*/ 
	| expression_list
	;
expression_list: 
	expression
	| expression COMMA expression_list
	;
expression: 
	simple_expression
	| simple_expression relop simple_expression
	;
simple_expression: 
	term 
	| term addop simple_expression
	;
term: 
	factor | factor multop term
	;
factor: 
	INT 
	| FLOAT 
	| variable 
	| procedure_statement 
	| NOT factor 
	| sign factor %prec UMINUS
	;
sign: 
	PLUS | MINUS
	;
relop: 
	GREATER		{ strcpy($$,$1); }
	| EQGREATER { strcpy($$,$1); }
	| LESS		{ strcpy($$,$1); }
	| EQLESS	{ strcpy($$,$1); }
	| EQUAL		{ strcpy($$,$1); }
	| NEQUAL	{ strcpy($$,$1); }
	| IN		{ strcpy($$,$1); }
	;
addop: 
	PLUS | MINUS
	;
multop:
	MUL | DIV
	;
%%

main(int argn,char** argv)
{
	if(argn>1)
		yyin=fopen(argv[1], "r");
	else
	{
		char buffer[256];
		printf("Type file name :\n");
		scanf("%s",buffer);
		yyin=fopen(buffer, "r");
	}
	yyparse();
	printf("Success");
}

yyerror(s)
char *s;
{
  fprintf(stderr,"%s in line %d\n",s, line);
  exit(1);
}

statement_error(s)
char *s;
{
  fprintf(stderr,"%s in line %d\n",s, statement_line);
  exit(1);
}

struct symbol {
    char name[256];
    struct symbol *next;
};

struct symbol_table {
    char scope_name[256];
	int reference_count;
	struct symbol *symbol_list;
	struct symbol_table *next;
};

struct symbol_table *symbol_table_list;

void push_symbol_table(char* scope)
{
	struct symbol_table* stp = (struct symbol_table *) malloc(sizeof(struct symbol_table));
	strcpy(stp->scope_name,scope);
	stp->reference_count = 0;
	stp->symbol_list = NULL;
	stp->next = symbol_table_list;
	symbol_table_list = stp;
}

void pop_symbol_table()
{
	struct symbol_table* stp = symbol_table_list;
	struct symbol* sp = NULL;
	while(stp->symbol_list)
	{
		sp = stp->symbol_list->next;
		free(stp->symbol_list);
		stp->symbol_list = sp;
	}
	stp = symbol_table_list->next;
	free(symbol_table_list);
	symbol_table_list = stp;
}

/*
	Return Value
	- Successed			: 1
	- Duplicated symbol : 0
*/
int add_symbol(char* name)
{
	struct symbol* sp = symbol_table_list->symbol_list;
	while(sp)
	{
		if(strcmp(sp->name,name)==0)
			return 0;
		sp=sp->next;
	}
	sp = (struct symbol *) malloc(sizeof(struct symbol));
	strcpy(sp->name, name);
	sp->next = symbol_table_list->symbol_list;
	symbol_table_list->symbol_list = sp;
	return 1;
}

int lookup_symbol(char* name)
{
	struct symbol_table* stp = symbol_table_list;
	struct symbol* sp = NULL;
	while(stp)
	{
		sp = stp->symbol_list;
		while(sp)
		{
			if(strcmp(sp->name,name)==0)
				return 1;
			sp=sp->next;
		}
		stp=stp->next;
	}
	return 0;
}