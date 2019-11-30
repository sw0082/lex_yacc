%token HI BYE

%%

program: 
         hi bye
        ;

hi:     
        HI     { printf("Hello World\n");   }
        ;
bye:    
        BYE    { printf("Bye World\n"); exit(0); }
         ;