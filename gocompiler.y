%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "gocompiler.h"
int yylex(void);
void yyerror (char *s);
global* gtable = NULL;
node* head= NULL;
node* aux=NULL;
node* aux2=NULL;
node* aux3=NULL;
node* auxtype;
funcDecl* ver = NULL;
funcDecl* ver2 = NULL;
funcDecl * auxfunc = NULL;
funcDecl* helper = NULL ;
varDecl* vir = NULL;
varDecl* vir2 = NULL;
parameters *input=NULL; 
parameters *input2=NULL;
extern int errors;
char * n_type;
char * id;
int verify;
int brother = 0;
int order = 0;
int errorSem = 0;
char  * errorDefine = NULL;


save * saveStat( char *id ,int line, int column ){
        save *new = (save*)malloc(sizeof(save));
        new->id = (char*)strdup(id);
        new->line = line;
        new->column = column;
        return new;
}


node* create(char* type,char* id, int line, int column){
    node* aux = (node*)malloc(sizeof(node));
    aux->type = (char*)strdup(type);
    if(id != NULL){
        aux->id = (char*)strdup(id);
    }
    else{
        aux->id = NULL;
    }
    if(line!=0){
            aux->line = line;
    }
    if(column!=0){
            aux -> column = column;
    }
    aux->son = NULL;
    aux->brother = NULL;
    return aux;
}
void createSon(node *father,node *son){
    if(father == NULL || son == NULL){
        return;
    }
    father->son = son;
}
void createBrother(node *origBro,node *newBro){
    if(origBro == NULL || newBro == NULL){
        return;
    }
    node* aux= origBro;
    while(aux->brother != NULL){
        aux = aux->brother;
    }
    aux->brother = newBro;
}

void printTree(node* curr,int no){
        if(curr == NULL ){
                return;
        }
        else if(strcmp(curr->type, "NULL") != 0 ){   
                for(int i = 0; i < no; i++){
                        printf("..");
                }
                if(curr->id == NULL)
                        printf("%s\n",curr->type);
                if(curr->id != NULL){
                        printf("%s(%s)\n",curr->type,curr->id);
                }
        }
        if(curr->son!=NULL){
              printTree(curr->son,no+1);  
        }
        if(curr->brother!=NULL){
             printTree(curr->brother,no);  
        }

       
}
void createTypes(node * no){
        n_type = no -> son -> type;
        no = no -> brother;
        while(strcmp(no->type,"VarDecl")==0){
                aux2=create(n_type,NULL,0,0);
                if (no->son->brother == NULL){  
                      aux3=create(no ->son ->type,no -> son -> id,no -> son -> line,no -> son -> column);
                      createSon(no, aux2);
                      createBrother(aux2,aux3);
                 }
                 no=no->brother;
        }  
        brother=0;        

}

//Meta 3- Tabelas
char* tableType(node* no){
        char *name = (char*)malloc(sizeof(50));
        if(strcmp(no->type,"Int")==0){
                strcpy(name,"int");
        }
        else if(strcmp(no->type,"Float32")==0){
                strcpy(name,"float32");
        }
        else if(strcmp(no->type,"Bool")==0){
                strcpy(name,"bool");
        }
        else if(strcmp(no->type,"String")==0){
                strcpy(name,"string");
        }
        return name;
}

void  addvarDecl(varDecl *vard,funcDecl *funcd){
        varDecl* taux= funcd->vardecl;
        while(taux -> next !=NULL){
                taux=taux->next;
        }
        taux->next=vard;

}

void  addGlobalvarDecl(node* no,varDecl *vari ,int order){
        varDecl *vard = (varDecl*)malloc(sizeof(varDecl));
        varDecl*taux= vari;
        while(taux->next!=NULL){
                taux=taux->next;
        }
        vard->name = no->son->brother->id;
        vard->line = no->son->brother->line;
        vard->column = no->son->brother->column;
        vard->type=tableType(no->son);
        vard->order = order;
        vard->check = 1;
        vard->next=NULL;
        taux->next=vard;
        aux= no;

}

int verifyexistenceVar2(node *no, funcDecl * funcd){
        vir = funcd->vardecl->next;
        
        if(strcmp(no->id, funcd->name)==0){
                return 1;
        }

        while(vir != NULL){
                if(strcmp(vir->name,no->id)==0)
                        return 1;
                vir = vir -> next;                
        }
        if(funcd->params != NULL){
                input = funcd->params;
                while(input != NULL){
                        if(strcmp(input->name,no->id)==0)
                                return 1;
                        input = input -> next;                
                }
        }
       return 0;
}

void bodyTable(node *no,funcDecl *funcd){
        varDecl* taux = (varDecl*)malloc(sizeof(varDecl));
        node* prev;
        if(strcmp(no->type,"VarDecl")== 0){
                prev= no->son;
                aux2 = prev->brother;
                while(aux2 != NULL){
                        if(strcmp(aux2->type,"Id")==0){
                                taux->name = aux2->id;
                                taux->type = tableType(prev);
                                taux->line = aux2 -> line;
                                taux->column = aux2 -> column;
                                taux->check = 0;
                        }
                       if (verifyexistenceVar2(aux2,funcd)==1){
                                printf("Line %d, column %d: Symbol %s already defined\n",aux2->line, aux2->column, aux2->id);
                        }
                        else{
                                addvarDecl(taux,funcd);
                        }
                        prev = aux2;
                        aux2 = aux2->brother;
                }
        }
        if(no->son != NULL){
                bodyTable(no->son,funcd);        
        }
        if(no->brother != NULL){
                bodyTable(no->brother,funcd);        
        }
}

int verifyexistenceParams(node *no, parameters * pdecl){
        input2 = pdecl;
        while(input2 != NULL){
                if(strcmp(input2->name, no->son->brother->id)==0)
                        return 1;
                input2 = input2 -> next;                
        }
        return 0;
}


funcDecl * insertparams(node * aux2, funcDecl * newf){  
        parameters* parames = (parameters*)malloc(sizeof(parameters));
        parames->type = tableType(aux2->son);
        parames->name = aux2->son->brother->id;
        parames->next = NULL;
        input=parames;
        aux2 = aux2 -> brother;
        while(strcmp(aux2->type, "NULL")!=0){
                if (verifyexistenceParams(aux2, input)==1){
                        printf("Line %d, column %d: Symbol %s already defined\n",aux2->son->brother->line, aux2->son->brother->column, aux2->son->brother->id);
                }
                parameters* param = (parameters*)malloc(sizeof(parameters));
                param->type = tableType(aux2->son);
                param->name = aux2->son->brother->id;
                param->next = NULL;
                parames->next = param;
                parames = parames->next;
                aux2 = aux2->brother;
        } 
        newf->params = input; 
        return newf;   
}

void addTable(node *no,funcDecl *fdecl,int order){
        funcDecl *fnew =  (funcDecl*)malloc(sizeof(funcDecl));
        funcDecl *faux = fdecl;
        varDecl* vaux = (varDecl*)malloc(sizeof(varDecl));
        vaux->next = NULL;
        aux= no->son->son;
        fnew->name = aux->id;
        aux= aux->brother;
        if(strcmp(aux->type, "FuncParams")==0){
                fnew->type = "none";
        }
        else{
                fnew->type = tableType(aux);
                aux = aux->brother;
        }
        if(aux->son!= NULL){
                fnew = insertparams(aux->son,fnew);
        }
        aux = no->son->brother;
        fnew->vardecl = vaux; 
        bodyTable(aux,fnew);
        while(faux->next != NULL){
                faux = faux->next;
        }
        fnew->order = order;
        faux->next = NULL;
        faux->next = fnew;
        aux=no;
}

int verifyexistenceGlob(node *no, funcDecl * fdecl,varDecl * vdecl){
        
        ver2 = fdecl->next;
        while(ver2 != NULL){
                if(strcmp(ver2->name, no->id)==0)
                        return 1;
                ver2 = ver2 -> next;                
        }
        vir2 = vdecl->next;
       while(vir2 != NULL){
                if(strcmp(vir2->name,no->id)==0)
                        return 1;
                vir2 = vir2-> next;                
        }
        return 0;
}


void globalTableMaker(varDecl *vaux, funcDecl *faux, int order){
        if(vaux == NULL && faux == NULL){
                return;
        }
        parameters *params;
        int cont;
        if(faux != NULL && faux->order == order){
                printf("%s\t(",faux->name);
                params = faux->params;
                cont=0;
                while(params!=NULL){
                        if(cont == 0){
                                printf("%s",params->type);
                                cont = 1;
                        }
                        else if(cont == 1){
                                printf(",%s",params->type);
                        }
                        params = params->next;
                }
                printf(")\t%s\n",faux->type);
                faux = faux -> next;
        }else{
                printf("%s\t",vaux->name);
                printf("\t%s\n",vaux->type);
                vaux = vaux -> next;
        }
        globalTableMaker(vaux,faux,order+1);
}

void printTable(global *gtable){
        funcDecl  *faux = gtable->funcdecl;
        varDecl   *vaux = gtable->vardecl;
        /*if(vaux -> next == NULL && faux -> next == NULL){
                return;
        }*/
        int order = 0;
        parameters *params;
        int cont;
        printf("===== Global Symbol Table =====\n");
        faux = faux->next;
        vaux = vaux->next;
        globalTableMaker(vaux,faux,order);
        faux = gtable->funcdecl->next;
        while(faux != NULL){
                printf("\n");
                printf("===== Function %s(",faux->name);
                params = faux->params;
                cont = 0;
                while(params!=NULL){
                        if(cont == 0){
                                printf("%s",params->type);
                                cont = 1;
                        }
                        else if(cont == 1){
                                printf(",%s",params->type);
                        }
                        params = params->next;
                }
                printf(") Symbol Table =====\n");
                printf("return\t\t%s\n",faux->type);
                params = faux->params;
                while(params!=NULL){
                        printf("%s\t\t%s\tparam\n",params->name,params->type);
                        params = params->next;
                }
                vaux=faux->vardecl;
                vaux = vaux->next;
                while(vaux!=NULL){
                        printf("%s\t\t%s\n",vaux->name,vaux->type);
                        vaux = vaux->next;

                }
                faux = faux->next;
        }
        printf("\n");

}

void printAST(node * curr, int no){
        if(strcmp(curr->type, "NULL") != 0 ){   
                for(int i = 0; i < no; i++){
                        printf("..");
                }                
                if(curr->anote != NULL && curr->id != NULL ){
                        printf("%s(%s) - %s\n", curr->type, curr->id, curr->anote);
                }        
                else if(curr->anote != NULL && curr->id == NULL && strcmp(curr->anote,"")!=0)
                        printf("%s - %s\n",curr->type, curr->anote);
                else if(curr->id == NULL)
                        printf("%s\n",curr->type);
                else if(curr->id != NULL)
                        printf("%s(%s)\n",curr->type,curr->id);
        }       
        if(curr->son!=NULL){
              printAST(curr->son,no+1);  
        }
        if(curr->brother!=NULL){
             printAST(curr->brother,no);  
        }


}

void putIdAnoted(node * curr, node * funcDecl){
        int help = 0;
        ver = gtable -> funcdecl -> next;
        while(ver != NULL){ //encontrar função nas tabelas
                if(strcmp(ver -> name, funcDecl->son->son->id ) == 0){
                        helper = ver; 
                }
                ver = ver -> next;
        }                
        vir = helper-> vardecl -> next;
        while(vir != NULL){ //procurar dentro da função
                if(strcmp(vir -> name, curr -> id ) == 0){
                        if(vir -> line > curr->line)
                                break;
                        vir->check = 1;
                        curr -> anote = vir -> type;
                        help = 1;
                        break;
                 }        
                      
        vir = vir ->next;
        }if (help == 0){
               input = helper -> params;
                while( input != NULL ){ //procurar nos parametros da função
                         if(strcmp(input -> name, curr -> id ) == 0){
                                curr -> anote = input -> type;
                                help = 1;
                                break;
                }        
                input = input -> next;
                }
        }if (help == 0){ // procurar var nas declarações globais
                vir = gtable -> vardecl -> next;
                while(vir != NULL){
                        if(strcmp(vir -> name, curr -> id ) == 0){
                                       // vir -> check = 1;
                                        curr -> anote = vir -> type;
                                        help = 1;
                                        break;
                        }        
                        
                        vir = vir ->next;
                }
        }if (help == 0){
           curr->anote = "undef";
           printf( "Line %d, column %d: Cannot find symbol %s\n",curr->line, curr->column, curr->id);
           errorSem = 1;
   
        }
}

char* transform(funcDecl* funcdecl){

        input = funcdecl -> params;
        char *name = (char*)malloc(sizeof(char) * 100);
        strcat(name,"(");
        while(input!=NULL){
                strcat(name,input->type);
                if(input->next != NULL){
                       strcat(name,",");  
                }
                input = input -> next;
        }
        strcat(name,")");
        return name;
        
}

int checkThis(funcDecl* funcThis,node *no){
      if((funcThis->params == NULL && no->brother != NULL) || (funcThis->params != NULL && no->brother == NULL) ){
                return 0;
       }else if(funcThis->params == NULL && no->brother == NULL ){
                return 1;        
       }  
        input = funcThis -> params;
        aux2 = no->brother;
        while(aux2!= NULL){
                if( strcmp(aux2->anote, input->type)!=0) {
                        return 0;
                }       
                if((input->next == NULL && aux2->brother == NULL) || (input->next == NULL && strcmp(aux2->brother->type, "NULL")==0)){
                        return 1;
                }
                else if((input->next == NULL && aux2->brother != NULL) || (input->next != NULL && aux2->brother == NULL )|| (input->next == NULL && strcmp(aux2->brother->type, "NULL")!=0) || (input->next != NULL && strcmp(aux2->brother->type, "NULL")==0 )) {
                        return 0;
                 } 
         aux2 = aux2 -> brother; 
         input = input -> next;
        }
        return 0;
}


char * findCallType(funcDecl * func, node * no){

        ver = func->next;
        while(ver != NULL) {
                if(strcmp(ver->name, no->id)==0){
                        if(strcmp(ver->type, "none")!=0)
                                return  ver->type;
                }
        ver = ver -> next;
        }
        return "";
}

void callError(node* no){

        aux = no -> brother;
        char *error = (char*)malloc(sizeof(char) * 1000);
        sprintf(error,"Line %d, column %d: Cannot find symbol %s",no->line, no->column, no->id);
        strcat(error,"(");
        while(aux!=NULL && strcmp(aux->type,"NULL")!=0){
                strcat(error,aux->anote);
                if(aux->brother != NULL && strcmp(aux->brother->type,"NULL")!=0){
                       strcat(error,",");  
                }
                aux = aux -> brother;
        }
        strcat(error,")");
        printf("%s\n",error);
        
}

int checkOctal(char * id){
        if( id[0] != '0')
                return 0;
        if(id[1] == 'x' || id[1] == 'X' )
                return 0;
        for (int i = 0; i<sizeof(id);i++){
                if(id[i]== '8' || id[i]== '9'){
                        return 1;
                }
        }
        return 0;
}

char * transformOperator(char * type){
        if(strcmp(type,"Eq")==0){
                return "==";
        }else if(strcmp(type,"Lt")==0){
                return "<";
        }else if(strcmp(type,"Le")==0){
                return "<=";
        }else if(strcmp(type,"Ge")==0){
                return ">=";
        }else if(strcmp(type,"Gt")==0){
                return ">";
        }else if(strcmp(type,"Not")==0){
                return "!";
        }else if(strcmp(type,"And")==0){
                return "&&";
        }else if(strcmp(type,"Or")==0){
                return "||";
        }else if(strcmp(type,"Ne")==0){
                return "!=";
        }else if(strcmp(type,"Mod")==0){
                return "%";
        } else if(strcmp(type,"Assign")==0){
                return "=";
        } else if(strcmp(type,"Mul")==0){
                return "*";
        }else if(strcmp(type,"Div")==0){
                return "/";
        }else if(strcmp(type,"Sub")==0 || strcmp(type,"Minus")==0){
                return "-";
        }else if(strcmp(type,"Add")==0 || strcmp(type,"Plus")==0){
                return "+";
        }                                             
        return "";
        
}

void putAnoted(node * curr, node * funcDecl){
        curr->here = 1;
        auxfunc = gtable -> funcdecl -> next;
        int exist = 0;
        if(strcmp(curr->type, "Eq") == 0    || strcmp(curr->type, "Lt") == 0 || strcmp(curr->type, "Le") == 0 
        || strcmp(curr->type, "Ge") == 0    || strcmp(curr->type, "Gt") == 0 || strcmp(curr->type, "Not") == 0 ||  
           strcmp(curr->type, "And") == 0   || strcmp(curr->type, "Or") == 0 || strcmp(curr->type, "Ne") == 0  ){
                curr -> anote = "bool";
                putAnoted(curr->son, funcDecl);
                if(strcmp(curr->type, "And")==0 || strcmp(curr->type, "Or")==0){
                        if(strcmp(curr->son->anote,"bool")!=0 || strcmp(curr->son->brother->anote,"bool")!=0){
                                 printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column, transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);
                        }        
                }else if(strcmp(curr->type, "Not")==0 && strcmp(curr->son->anote, "bool")!=0){
                         printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", curr->line, (curr->column)-1,transformOperator(curr->type), curr->son->anote);
                      
                }else if(strcmp(curr->type, "Lt")==0 || strcmp(curr->type, "Gt")==0 || strcmp(curr->type, "Ge")==0 || strcmp(curr->type, "Le")==0){
                        if((strcmp(curr->son->anote,"bool")==0 && strcmp(curr->son->brother->anote,"bool")==0) || strcmp(curr->son->anote,curr->son->brother->anote)!=0  || (strcmp(curr->son->anote,"undef" )==0 && strcmp(curr->son->anote, "undef" )==0)){
                                 printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column, transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);
                        }
                }else if(strcmp(curr->type, "Eq")==0 || strcmp(curr->type, "Ne")==0){
                        if(strcmp(curr->son->anote,curr->son->brother->anote)!=0  || (strcmp(curr->son->anote,"undef" )==0 && strcmp(curr->son->anote, "undef" )==0)){
                               printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column,transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);  
                        }
                }
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }
        if(strcmp(curr->type, "Mod") == 0 ){

              putAnoted(curr->son,funcDecl);
               if(strcmp(curr->son->anote,"int")!=0 || strcmp(curr->son->brother->anote,"int")!=0){
                                 printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column, transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);
                                 curr -> anote = "undef";
                }else{
                        curr->anote = "int";
                }
              if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }
        if(strcmp(curr->type, "Id") == 0){
                putIdAnoted(curr,funcDecl);
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }if(strcmp(curr->type, "IntLit") == 0){
                curr -> anote = "int";
                if(checkOctal(curr->id) == 1){
                        printf("Line %d, column %d: Invalid octal constant: %s\n",curr->line,curr->column,curr->id);
                        //curr -> anote = "undef";
                }
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }if(strcmp(curr->type, "RealLit") == 0){
                curr -> anote = "float32";
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }   
        }if(strcmp(curr->type, "StrLit") == 0){
                curr -> anote = "string";
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
        }              
        }if(strcmp(curr->type, "Assign") == 0){
              putAnoted(curr->son,funcDecl);
              if((strcmp(curr->son->anote,"undef" )==0 && strcmp(curr->son->anote, "undef" )==0) || strcmp(curr->son->anote,curr->son->brother->anote)!=0){
                      printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column, transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);
                      curr->anote = "undef";
              }else{
                      curr->anote = curr -> son -> anote;
              }
  
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }  
        }if(strcmp(curr->type, "Mul") == 0 || strcmp(curr->type, "Div")==0 || strcmp(curr->type, "Sub") == 0){
                putAnoted(curr->son, funcDecl);   
                 if((strcmp(curr->son->anote, curr->son->brother->anote )!=0) || (strcmp(curr->son->anote,"string")==0 && strcmp(curr->son->brother->anote,"string")==0) ||  (strcmp(curr->son->anote,"bool")==0 && strcmp(curr->son->brother->anote,"bool")==0) || (strcmp(curr->son->anote,"undef" )==0 && strcmp(curr->son->anote, "undef" )==0) ){
                      printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column,transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);
                      curr->anote = "undef";
                }else{
                       curr -> anote = curr -> son -> anote;
                }
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }if(strcmp(curr->type, "Add") == 0){
                putAnoted(curr->son, funcDecl); 
                if( strcmp(curr->son->anote,curr->son->brother->anote )!=0 || (strcmp(curr->son->anote,"bool")==0 && strcmp(curr->son->brother->anote,"bool")==0) || (strcmp(curr->son->anote,"undef" )==0 && strcmp(curr->son->anote, "undef" )==0) ){
                        printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", curr->line, curr->column,transformOperator(curr->type), curr->son->anote, curr->son->brother->anote);
                        curr -> anote = "undef";
                }else{
                        curr -> anote = curr -> son -> anote;
                }       
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }if(strcmp(curr->type, "Plus") == 0 || strcmp(curr->type, "Minus") == 0 ){
                putAnoted(curr->son, funcDecl); 
               if(strcmp(curr->son->anote, "string")==0 || strcmp(curr->son->anote, "bool")==0 || strcmp(curr->son->anote, "undef")==0){
                        printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", curr->line, curr->column, transformOperator(curr->type), curr->son->anote);
                        curr -> anote = "undef";
                }else{
                        curr -> anote = curr -> son -> anote;
                }       
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
         }if(strcmp(curr->type, "ParseArgs") == 0){
                putAnoted(curr->son, funcDecl); 
               if(strcmp(curr->son->anote,"int" )!=0 || strcmp(curr->son->brother->anote,"int" )!=0 ){
                     printf("Line %d, column %d: Operator strconv.Atoi cannot be applied to types %s, %s\n", curr->line, curr->column, curr->son->anote, curr->son->brother->anote);
                     curr -> anote = "undef";
                }else{
                        curr->anote = curr->son->anote;
                }
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }        
        }if(strcmp(curr->type, "Return") == 0){
               if(curr->son != NULL){    
                        putAnoted(curr->son, funcDecl);
                        if(strcmp(curr->son->anote, tableType(funcDecl->son->son->brother)) != 0){
                               printf("Line %d, column %d: Incompatible type %s in return statement\n", curr->son->line, curr->son->column, curr->son->anote);
                        }
                }else if(strcmp(funcDecl->son->son->brother->type,"FuncParams")!=0){
                        printf("Line %d, column %d: Incompatible type none in return statement\n", curr->line, curr->column);
                }
        }if(strcmp(curr->type, "Print") == 0){     
                putAnoted(curr->son, funcDecl);
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }if(strcmp(curr->type, "If") == 0 ){     
                putAnoted(curr->son, funcDecl);
                if(strcmp(curr->son->anote, "bool")!=0 ){
                        printf("Line %d, column %d: Incompatible type %s in if statement\n", curr->son->line, curr->son->column, curr->son->anote );
                }
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }


        }if(strcmp(curr->type, "For") == 0){     
                putAnoted(curr->son, funcDecl);
                if(strcmp(curr->son->type, "Block")==0){
      
                }else if(strcmp(curr->son->anote, "bool")!=0  && strcmp(curr->son->type, "Block")!=0 ){
                        printf("Line %d, column %d: Incompatible type %s in for statement\n", curr->son->line, curr->son->column, curr->son->anote );
                }if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }

        }if(strcmp(curr->type, "Block")==0){
                if(curr->son != NULL){
                        putAnoted(curr->son, funcDecl);
                }
                if(curr -> brother != NULL){
                        putAnoted(curr->brother, funcDecl);
                }
        }
       if(strcmp(curr->type, "Call") == 0){     
                exist = 0;
                curr -> anote = findCallType(gtable->funcdecl, curr->son);
                if(curr->son->brother != NULL){
                        putAnoted(curr->son->brother, funcDecl);
                }
                int checkflag = 0;
                while(auxfunc != NULL ){
                        if(strcmp(auxfunc->name, curr->son->id)==0){
                                checkflag=1;
                                if(checkThis(auxfunc, curr->son) == 0){
                                        curr->anote = "undef";
                                        //curr->son->anote = "undef";
                                        if(curr->son->brother == NULL   ){
                                                printf("Line %d, column %d: Cannot find symbol %s()\n",curr->son->line, curr->son->column, curr->son->id);
                                                break;
                                        }
                                        else{
                                                callError(curr->son);
                                                break;
                                        }  
                                }            
                                if(auxfunc->params != NULL ){
                                        curr->son->anote = transform(auxfunc);
                                }else{
                                        curr->son->anote = "()";
                                }
                                break;      
                        }
                auxfunc = auxfunc -> next;    
                }
                if (checkflag  == 0){
                        curr->anote = "undef";
                        //curr->son->anote = "undef";
                        if(curr->son->brother == NULL   ){
                                printf("Line %d, column %d: Cannot find symbol %s()\n",curr->son->line, curr->son->column, curr->son->id);
                        }
                        else{
                                callError(curr->son);
                        }
                }
                 if(curr -> brother != NULL )
                        putAnoted(curr->brother, funcDecl);       
        } 
   
}

void makeAnoted(node* curr){
        if(strcmp(curr->type, "FuncDecl") == 0 ){
                if(curr->skip == 1)
                        aux = curr;
                else{   
                        if(curr->brother!=NULL){
                                makeAnoted(curr->brother); 
                                return;
                        }
                }
        }                        
        if(strcmp(curr->type, "Assign") == 0 || strcmp(curr->type, "Or") == 0        || strcmp(curr->type, "And") == 0
        || strcmp(curr->type, "Eq") == 0     || strcmp(curr->type, "Ne") == 0        || strcmp(curr->type, "Lt") == 0
        || strcmp(curr->type, "Ge") == 0     || strcmp(curr->type, "Add") == 0       || strcmp(curr->type, "Sub") == 0
        || strcmp(curr->type, "Mul") == 0    || strcmp(curr->type, "Div") == 0       || strcmp(curr->type, "Mod") == 0
        || strcmp(curr->type, "Not") == 0    || strcmp(curr->type, "Minus") == 0     || strcmp(curr->type, "Plus") == 0
        || strcmp(curr->type, "Call") == 0   || strcmp(curr->type, "ParseArgs") == 0 || strcmp(curr->type, "Return") == 0  
        || strcmp(curr->type, "Gt") == 0     || strcmp(curr->type, "Le") == 0        || strcmp(curr->type, "Print") == 0 || strcmp(curr->type, "If") == 0
        || strcmp(curr->type, "For") == 0){
                       if(curr -> here != 1)
                                putAnoted(curr, aux); 
        
        }
        if(curr->son!=NULL){
              makeAnoted(curr->son);  
        }
        if(curr->brother!=NULL){
             makeAnoted(curr->brother);  
        }


}

void printUnusedVars(){
        if(gtable->funcdecl->next != NULL){
                ver = gtable -> funcdecl->next;
                        while(ver!=NULL){
                                vir = ver -> vardecl -> next;
                                while( vir!= NULL){
                                        if(vir->check != 1){
                                                 printf("Line %d, column %d: Symbol %s declared but never used\n", vir->line, vir->column, vir->name);
                                         }
                                vir = vir -> next;         
                                 }
                        ver = ver -> next;        
                         }
        }
}

void makeTable(node *no, int flag){
        if(strcmp(no->son->type, "NULL")==0)
                return;
        errorDefine =(char*) malloc((100)*sizeof(char));        
        gtable = (global *)malloc(sizeof(global));        
        funcDecl* funcdecl = (funcDecl*)malloc(sizeof(funcDecl));
        funcdecl->next = NULL;
        gtable->funcdecl = funcdecl; 
        varDecl* vardecl = (varDecl*)malloc(sizeof(varDecl));
        vardecl->next = NULL;
        gtable->vardecl = vardecl; 
        aux=no;
        aux = aux -> son;
        while(aux != NULL){
                if(strcmp(aux->type, "FuncDecl")==0){
                        verify=verifyexistenceGlob(aux->son->son, gtable->funcdecl,gtable->vardecl);
                        if(verify == 0){
                                addTable(aux,gtable->funcdecl,order);
                                aux->skip = 1;
                                order++;
                        }
                        else{
                                printf("Line %d, column %d: Symbol %s already defined\n",aux->son->son->line, aux->son->son->column, aux->son->son->id);
                                //addTable(aux,gtable->funcdecl,order);
                        }
                }
                else if(strcmp(aux->type, "VarDecl")==0){
                       verify=verifyexistenceGlob(aux->son->brother, gtable->funcdecl,gtable->vardecl);
                        if(verify == 0){
                                addGlobalvarDecl(aux,gtable->vardecl,order);
                                order++;
                        }
                        else{
                               printf("Line %d, column %d: Symbol %s already defined\n",aux->son->brother->line, aux->son->brother->column, aux->son->brother->id);
                               //addGlobalvarDecl(aux,gtable->vardecl,order);
                        }
                }
        aux = aux -> brother;
        }
        makeAnoted(no);
        printUnusedVars(); 
        if( flag == 0){
                printTable(gtable);
                printAST(no, 0);
        }
}

%}
%union{
 struct node * node;
 struct save * saveStat;
}

%right ASSIGN
%left OR
%left AND
%left EQ NE LT LE GT GE
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left LPAR RPAR LSQ RSQ
%nonassoc bec


%token <saveStat> ID  INTLIT REALLIT STRLIT AND ASSIGN STAR DIV EQ GE GT LE LSQ LT MINUS MOD NE NOT OR PLUS RSQ RETURN  PARSEINT
%token<node> NUMBER SEMICOLON BLANKID PACKAGE COMMA  
LBRACE LPAR RBRACE RPAR ELSE FOR IF VAR INT 
FLOAT32 BOOL STRING PRINT FUNC CMDARGS RESERVED 


%type<node>  Program Declarations VarDeclaration VarSpec Type Parameters FuncBody
auxParameters VarsAndStatements auxVarSpec FuncDeclaration Statement auxStatement
Expr FuncInvocation ParseArgs auxFuncInvocation 
%%

Program: PACKAGE ID SEMICOLON  Declarations             {head = create("Program",NULL,0,0); createSon(head,$4);} 
;
Declarations:%empty                                     {$$ = create("NULL",NULL,0,0);}
        |VarDeclaration SEMICOLON Declarations          {$$ = $1; createBrother($1,$3);}     
        |FuncDeclaration SEMICOLON Declarations         {$$ = $1; createBrother($1,$3);} 
        ;

VarDeclaration:VAR VarSpec                             {$$ = $2;}
        |VAR LPAR VarSpec SEMICOLON RPAR               {$$ = $3;}
        ;

VarSpec:ID auxVarSpec Type                             {$$ = create("VarDecl",NULL,0, 0);
                                                        aux = create("Id",$1->id, $1->line, $1->column);
                                                        createSon($$,$3);
                                                        createBrother($3,aux);
                                                        createBrother($$,$2); 
                                                        if (brother == 1)
                                                                createTypes($$);   
                                                        brother=0;                 
                                                        }
        ;

auxVarSpec: %empty                                      {$$ = create("NULL",NULL,0,0);}

        | COMMA ID auxVarSpec                           {$$ = create("VarDecl",NULL,0,0);
                                                        aux = create("Id",$2->id,$2->line,$2->column);
                                                        createSon($$,aux);
                                                        createBrother($$,$3);
                                                        brother=1;                                              
                                                        }
        ;

Type: INT                                               {$$=create("Int",NULL,0,0);}    
     | FLOAT32                                          {$$=create("Float32",NULL,0,0);}  
     | BOOL                                             {$$=create("Bool",NULL,0,0);}  
     | STRING                                           {$$=create("String",NULL,0,0);}  
     ;

FuncDeclaration:
                 FUNC ID LPAR Parameters  RPAR FuncBody                {$$=create("FuncDecl", NULL,0,0);aux=create("FuncHeader",NULL,0,0);createSon($$,aux);aux2 = create("Id",$2->id,$2->line,$2->column);createSon(aux,aux2);createBrother(aux2,$4);createBrother(aux,$6);}
                |FUNC ID LPAR Parameters RPAR Type FuncBody            {$$=create("FuncDecl", NULL,0,0);aux=create("FuncHeader",NULL,0,0);createSon($$,aux);aux2 = create("Id",$2->id,$2->line,$2->column);createSon(aux,aux2);createBrother(aux2,$6);createBrother($6,$4);createBrother(aux,$7);;} 
             ;
            

        
Parameters: %empty                                                      {$$=create("FuncParams",NULL,0,0);}
        |ID Type auxParameters                                          {$$=create("FuncParams",NULL,0,0);aux = create("ParamDecl",NULL,0,0);createSon($$,aux);aux2 = create("Id",$1->id,$1->line,$1->column);createSon(aux,$2);createBrother($2,aux2);createBrother(aux,$3);}
        ;

auxParameters: %empty                                                   {$$=create("NULL",NULL,0,0);}
        |COMMA ID Type auxParameters                            {
                                                                        $$=create("ParamDecl",NULL,0,0);
                                                                        createSon($$,$3);
                                                                        aux = create("Id",$2->id,$2->line, $2->column);
                                                                        createBrother($3,aux);
                                                                        createBrother($$,$4);
                                                                }
        ;


FuncBody:LBRACE VarsAndStatements RBRACE                                {$$=create("FuncBody",NULL,0,0);createSon($$,$2);}                   
        ;

VarsAndStatements:
        %empty                                                          {$$=create("NULL",NULL,0,0);}
        |SEMICOLON VarsAndStatements                                    {$$=$2;}
        |VarDeclaration SEMICOLON  VarsAndStatements                    {$$=$1;createBrother($1,$3);}
        |Statement SEMICOLON VarsAndStatements                          {$$=$1;createBrother($1,$3);} 
      
 ;   

Statement:ID ASSIGN Expr                                                                {$$=create("Assign",NULL,$2->line,$2->column);aux = create("Id",$1->id,$1->line, $1->column);createSon($$,aux);createBrother(aux,$3);}
        |LBRACE auxStatement RBRACE                                                     {if($2 != NULL && $2->brother != NULL && strcmp($2->brother->type,"NULL")!=0){$$=create("Block",NULL,0,0);createSon($$,$2);}else $$ = $2;}
        |IF Expr LBRACE auxStatement RBRACE                                             {$$=create("If",NULL,0,0);createSon($$,$2);aux = create("Block",NULL,0,0);createBrother($2,aux);createSon(aux,$4);aux2 = create("Block",NULL,0,0);createBrother(aux,aux2);}
        |IF Expr LBRACE auxStatement RBRACE ELSE LBRACE auxStatement RBRACE             {$$=create("If",NULL,0,0);createSon($$,$2);aux = create("Block",NULL,0,0);createBrother($2,aux);createSon(aux,$4);aux2 = create("Block",NULL,0,0);createBrother(aux,aux2);createSon(aux2,$8);}
        |FOR LBRACE auxStatement RBRACE                                                 {$$=create("For",NULL,0,0);aux = create("Block",NULL,0,0);createSon($$,aux);createSon(aux,$3);}    
        |FOR Expr LBRACE auxStatement RBRACE                                            {$$=create("For",NULL,0,0);createSon($$,$2);aux = create("Block",NULL,0,0);createBrother($2,aux);createSon(aux,$4);}
        |RETURN                                                                         {$$=create("Return",NULL,$1->line, $1->column);}
        |RETURN Expr                                                                    {$$=create("Return",NULL,$1->line, $1->column);createSon($$,$2);}  
        |FuncInvocation                                                                 {$$=$1;}
        |ParseArgs                                                                      {$$=$1;}     
        |PRINT LPAR Expr RPAR                                                           {$$=create("Print",NULL,0,0);createSon($$,$3);} 
        |PRINT LPAR STRLIT RPAR                                                         {$$=create("Print",NULL,0,0);aux = create("StrLit",$3->id,$3->line,$3->column);createSon($$,aux);}
        |error                                                                          {$$=create("NULL", NULL,0,0);}


;   
auxStatement:%empty                                                                      {$$=create("NULL", NULL,0, 0);}
            |Statement SEMICOLON auxStatement                                            {$$ = $1; createBrother($1,$3);} 
            ;

ParseArgs:ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR       {$$=create("ParseArgs", NULL,$5->line,$5->column);aux = create("Id",$1->id,$1->line, $1->column);createSon($$,aux); createBrother(aux,$9);}
         |ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                      {$$=create("NULL", NULL,0,0);}

         ;

FuncInvocation:ID LPAR RPAR                                             {$$=create("Call",NULL,0, 0);aux = create("Id",$1->id,$1->line,$1->column);createSon($$,aux);}     
              |ID LPAR Expr auxFuncInvocation RPAR                      {$$=create("Call",NULL,0, 0);aux = create("Id",$1->id,$1->line, $1->column);createSon($$,aux);createBrother(aux,$3);createBrother($3,$4);}    
              |ID LPAR error RPAR                                       {$$=create("NULL", NULL,0,0);}
              ;

auxFuncInvocation:%empty                                                {$$=create("NULL", NULL,0,0);}
                 |COMMA Expr auxFuncInvocation                          {$$ = $2; createBrother($2,$3);}     
                ;

Expr:  Expr OR Expr                                             {$$=create("Or", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr AND Expr                                            {$$=create("And", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr LT Expr                                             {$$=create("Lt", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr GT Expr                                             {$$=create("Gt", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr EQ Expr                                             {$$=create("Eq", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr NE Expr                                             {$$=create("Ne", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr LE Expr                                             {$$=create("Le", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr GE Expr                                             {$$=create("Ge", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr PLUS Expr                                           {$$=create("Add", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr MINUS Expr                                          {$$=create("Sub", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr STAR Expr                                           {$$=create("Mul", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |Expr DIV Expr                                            {$$=create("Div", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);} 
      |Expr MOD Expr                                            {$$=create("Mod", NULL,$2->line, $2->column);createSon($$,$1);createBrother($1,$3);}
      |NOT Expr       %prec bec                                 {$$=create("Not", NULL,$2->line, $2->column);createSon($$,$2);}
      |MINUS Expr       %prec bec                               {$$=create("Minus", NULL,$1->line, $1->column);createSon($$,$2);}
      |PLUS Expr         %prec bec                              {$$=create("Plus", NULL,$1->line, $1->column);createSon($$,$2);}
      |INTLIT                                                   {$$ = create("IntLit",$1->id,$1->line, $1->column);}
      |REALLIT                                                  {$$ = create("RealLit",$1->id,$1->line, $1->column);}
      |ID                                                       {$$ = create("Id",$1->id,$1->line, $1->column);}
      |FuncInvocation                                           {$$=$1;}
      |LPAR Expr RPAR                                           {$$=$2;}
      |LPAR error RPAR                                          {$$=create("NULL", NULL,0,0);}
      ;     


%%
