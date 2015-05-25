#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashmap.h"
#include "y.tab.h"

#define OK 0
#define ERRO_VAR_ALREADY_EXIST -1
#define ERRO_VAR_DONT_EXIST -2
#define ERRO_VAR_INVALID_TYPE -3


typedef enum eType{_INTS,_INTA} Type;

static map_t mVarMap;
static map_t mFuncMap;
static int addressCounter;

typedef struct sEntry{
    Type type;
    char *name;
    int memAdr;
} *Entry;

int initVarMap()
{
	addressCounter = 0;
	mVarMap = hashmap_new();
	return 0;
}

Entry containsVar(char* varName)
{
	Entry varEntry; //= (Entry) malloc(sizeof(Entry));
	
	if(!(hashmap_get(mVarMap, varName, (any_t*) &varEntry) == MAP_OK))
		varEntry = NULL;
	return varEntry;	
}

int decVar(char* varName, int size)
{
	if(!containsVar(varName))
	{
		Entry newVar = (Entry) malloc(sizeof(struct sEntry));
		if(size>1)
		{
			newVar->type = _INTA;
		}
		else
		{
			newVar->type = _INTS;
		}
		newVar->name = strdup(varName);
		newVar->memAdr = addressCounter;
		printf("%s -> %d\n", newVar->name, newVar-> memAdr);
		addressCounter+=size;

		hashmap_put(mVarMap, varName, (any_t) newVar);

		return OK;
	}
	return ERRO_VAR_ALREADY_EXIST;
}

int getMemAdd(char* varName)
{
	Entry varEntry;
	int memAddr = ERRO_VAR_DONT_EXIST;

	if(varEntry = containsVar(varName))
	{
		memAddr = varEntry->memAdr;
	}

	return memAddr;
}

int main(){
    yyparse();
    initVarMap();
    decVar("a",1);
    decVar("b",3);
    decVar("c",1);
    decVar("a",1);
    printf("%d\n", getMemAdd("a"));
    printf("%d\n", getMemAdd("b"));
    printf("%d\n", getMemAdd("c"));
    printf("%d\n", getMemAdd("d"));
    return 0; 
}
