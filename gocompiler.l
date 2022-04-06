%x COMMENTS
%option yylineno

%{
    /*
  João Costa 2014196905
  Hipólito   2016223273
  */
 #include "y.tab.h"
 #include <stdio.h>
 #include <string.h>
 #include "gocompiler.h"
int column = 1;
int flag;
int ident = 0;
int tempColumn, tempLine;
extern node* head;
int errors = 0;
%}
escape             (\\f|\\t|\\\\|\\\"|\\n|\\r)
letter             [a-zA-Z]|"_"
integer			       [0-9]+
identifier         ({letter})({letter}|{integer})*
intlit             ("0"?{integer}|"0"("x"|"X")([a-fA-F]|{integer})+)
strlit             \"(([^\\\n\r\"])|({escape}))*\"
invalidescape      \"(\\.|[^\\\n\r\"])*\"
unterstrlit        \"((\\.|[^\\\n\r\"])*)
reallit            (({integer}"."{integer}?)|("."{integer}))(("e"|"E")("+"|"-")?({integer}))?|{integer}("e"|"E")("+"|"-")?({integer})
reserved	         "--"|"++"|"break"|"case"|"chan"|"const"|"continue"|"default"|"defer"|"else"|"for"|"fallthrough"|"func"|"go"|"goto"|"if"|"import"|"interface"|"map"|"package"|"range"|"return"|"select"|"struct"|"switch"|"type"|"var"

%%

"\t"|" "	         {column+=yyleng;}
"\n"               {if(flag == 1){
                        if(ident == 1){
                          printf("SEMICOLON\n");
                          column = 1; 
                          ident = 0;
                        }
                    }else if(flag==2|| flag==3){
                        if(ident == 1){
                          column = 1; 
                          ident = 0;
                          return SEMICOLON;
                        }
                    }
                    column=1;
                          }
"\r"               {column=1;}
"//".*             {column += yyleng;}
"/*"               {BEGIN COMMENTS; tempColumn = column; tempLine = yylineno;  column+=yyleng;}
<COMMENTS>\n       {column = 1;}
<COMMENTS>.        {column+=yyleng;}
<COMMENTS>"*/"     {column+=yyleng; BEGIN 0;}
<COMMENTS><<EOF>>  {printf("Line %d, column %d: unterminated comment\n", tempLine, tempColumn); column+=yyleng; return 0;}

";"                {column += yyleng; ident = 0;if(flag==1) printf("SEMICOLON\n");if(flag==2|| flag==3)return SEMICOLON;}
"_"                {column += yyleng; ident = 0;if(flag==1) printf("BLANKID\n");if(flag==2|| flag==3)return BLANKID;}  
"package"          {column += yyleng; ident = 0;if(flag==1) printf("PACKAGE\n");if(flag==2|| flag==3)return PACKAGE;} 
"return"           {column += yyleng; ident = 1;if(flag==1) printf("RETURN\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return RETURN;}} ////
"&&"               {column += yyleng; ident = 0;if(flag==1) printf("AND\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return AND;}}  //
"="                {column += yyleng; ident = 0;if(flag==1) printf("ASSIGN\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return ASSIGN;}} //
"*"                {column += yyleng; ident = 0;if(flag==1) printf("STAR\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return STAR;}} //
","                {column += yyleng; ident = 0;if(flag==1) printf("COMMA\n");if(flag==2|| flag==3)return COMMA;}
"/"                {column += yyleng; ident = 0;if(flag==1) printf("DIV\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return DIV;}} //
"=="               {column += yyleng; ident = 0;if(flag==1) printf("EQ\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return EQ;}} //
">="               {column += yyleng; ident = 0;if(flag==1) printf("GE\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return GE;}} //
">"                {column += yyleng; ident = 0;if(flag==1) printf("GT\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return GT;}} //
"{"                {column += yyleng; ident = 0;if(flag==1) printf("LBRACE\n");if(flag==2|| flag==3)return LBRACE;}
"<="               {column += yyleng; ident = 0;if(flag==1) printf("LE\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return LE;}} //
"("                {column += yyleng; ident = 0;if(flag==1) printf("LPAR\n");if(flag==2|| flag==3)return LPAR;}
"["                {column += yyleng; ident = 0;if(flag==1) printf("LSQ\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return LSQ;}}
"<"                {column += yyleng; ident = 0;if(flag==1) printf("LT\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return LT;}} //
"-"                {column += yyleng; ident = 0;if(flag==1) printf("MINUS\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return MINUS;}} //
"%"                {column += yyleng; ident = 0;if(flag==1) printf("MOD\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return MOD;}} //
"!="               {column += yyleng; ident = 0;if(flag==1) printf("NE\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return NE;}} //
"!"                {column += yyleng; ident = 0;if(flag==1) printf("NOT\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return NOT;}} //
"||"               {column += yyleng; ident = 0;if(flag==1) printf("OR\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return OR;}} //
"+"                {column += yyleng; ident = 0;if(flag==1) printf("PLUS\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return PLUS;}} //
"}"                {column += yyleng; ident = 1;if(flag==1) printf("RBRACE\n");if(flag==2|| flag==3)return RBRACE;}
")"                {column += yyleng; ident = 1;if(flag==1) printf("RPAR\n");if(flag==2|| flag==3)return RPAR;}
"]"                {column += yyleng; ident = 1;if(flag==1) printf("RSQ\n");if(flag==2|| flag==3)return RSQ;}
"else"             {column += yyleng; ident = 0;if(flag==1) printf("ELSE\n");if(flag==2|| flag==3)return ELSE;}
"for"              {column += yyleng; ident = 0;if(flag==1) printf("FOR\n");if(flag==2|| flag==3)return FOR;}
"if"               {column += yyleng; ident = 0;if(flag==1) printf("IF\n");if(flag==2|| flag==3)return IF;}
"var"              {column += yyleng; ident = 0;if(flag==1) printf("VAR\n");if(flag==2|| flag==3)return VAR;} 
"int"              {column += yyleng; ident = 0;if(flag==1) printf("INT\n");if(flag==2|| flag==3)return INT;} //
"float32"          {column += yyleng; ident = 0;if(flag==1) printf("FLOAT32\n");if(flag==2|| flag==3)return FLOAT32;} //
"bool"             {column += yyleng; ident = 0;if(flag==1) printf("BOOL\n");if(flag==2|| flag==3)return BOOL;} //
"string"           {column += yyleng; ident = 0;if(flag==1) printf("STRING\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return STRING;}}//
"fmt.Println"      {column += yyleng; ident = 0;if(flag==1) printf("PRINT\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return PRINT;}} 
"strconv.Atoi"     {column += yyleng; ident = 0;if(flag==1) printf("PARSEINT\n");if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return PARSEINT;}}
"func"             {column += yyleng; ident = 0;if(flag==1) printf("FUNC\n");if(flag==2|| flag==3)return FUNC;}
"os.Args"          {column += yyleng; ident = 0;if(flag==1) printf("CMDARGS\n");if(flag==2|| flag==3)return CMDARGS;}
{reserved}         {column += yyleng; ident = 0;if(flag==1) printf("RESERVED(%s)\n", yytext);if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return RESERVED;}} 
{strlit}           {column += yyleng; ident = 1;if(flag==1) printf("STRLIT(%s)\n",yytext);if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return STRLIT;}} //
{invalidescape}	   {
                    ident = 0;
                    for(int i=0;i<yyleng;i++){
                      if(yytext[i]== '\\' ){
                        if(yytext[i+1]!='f' && yytext[i+1]!='n' && yytext[i+1]!='r' && yytext[i+1]!='"' && yytext[i+1]!='t' && yytext[i+1]!='\\'){
                          ident = 0;
                          printf("Line %d, column %d: invalid escape sequence (\\%c)\n", yylineno, column+i, yytext[i+1]); 
                        }  
                         else if(yytext[i+1] == '\\'){
                         i++;
                        }
                      }
                    }
                    column+=yyleng;
}
{unterstrlit}	     { for(int i=0;i<yyleng;i++){
                      if(yytext[i]== '\\' ){
                        if(yytext[i+1]!='f' && yytext[i+1]!='n' && yytext[i+1]!='r' && yytext[i+1]!='"' && yytext[i+1]!='t' && yytext[i+1]!='\\'){
                          ident = 0;
                          printf("Line %d, column %d: invalid escape sequence (\\%c)\n", yylineno, column+i, yytext[i+1]); 
                        }  
                         else if(yytext[i+1] == '\\'){
                         i++;
                      } 
                    }
                  } 
                      printf("Line %d, column %d: unterminated string literal\n", yylineno, column);ident=0; column+=yyleng;}
{identifier}       {column += yyleng; ident = 1;if(flag==1) printf("ID(%s)\n", yytext);if(flag==2|| flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return ID;}} //
{intlit}           {column += yyleng; ident = 1;if(flag==1) printf("INTLIT(%s)\n", yytext);if(flag==2 || flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return INTLIT;}} 
{reallit}          {column += yyleng; ident = 1;if(flag==1) printf("REALLIT(%s)\n", yytext);if(flag==2 || flag==3){yylval.saveStat = saveStat(strdup(yytext),yylineno,column-(int)yyleng);return REALLIT;}}
.		               {printf("Line %d, column %d: illegal character (%s)\n", yylineno, column, yytext); column+=yyleng;}

%%

int main(int argc, char * argv[])
{
    if(argc>1 && strcmp(argv[1],"-l")==0){
      flag = 1;
      yylex();
    }
    else if(argc>1 && strcmp(argv[1],"-t")==0){
      flag = 2;
      yyparse();
      if(errors==0)
        printTree(head,0);
    }
    else if (argc>1 && strcmp(argv[1],"-s")==0){
      flag = 3;
      yyparse();
      if(errors==0) //&& strcmp(head->son->type,"NULL") != 0
        makeTable(head,0);
      else
        makeTable(head,1);

    }
    else{
        flag = 2;
        yyparse();
        makeTable(head,1);
    }
return 0;
}

int yywrap()
{
return 1;
}

void yyerror (char *s) { 
     printf ("Line %d, column %d: %s: %s\n", yylineno, (int)(column-(int)yyleng), s, yytext);
     errors ++;
}