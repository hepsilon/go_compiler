#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct node{
    char *id;
    char *type;
	char *anote;
	int line;
	int column;
	int here;
	int skip;
    struct node *brother;
    struct node *son;
}node;

typedef struct save{
    char *id;
	int line;
	int column;
}save;

typedef struct global{
	struct varDecl *vardecl;
	struct funcDecl *funcdecl;
}global;

typedef struct varDecl{
	char *name;
	char *type;
	int line;
	int column;
	int order;
	int check;
	struct varDecl *next;
}varDecl;

typedef struct funcDecl{
	char * name;
	char * type;
	struct parameters *params;
	struct funcDecl *next; 
	struct varDecl *vardecl;
	int order;
}funcDecl;

typedef struct parameters{
	char *type;
	char *name;
	struct parameters *next;
}parameters;

void printTree(node* head, int no);
void makeTable(node *head,int flag);
save * saveStat(char *id,int line, int column);


