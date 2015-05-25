#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashmap.h"
#include "y.tab.h"

#define OK 0
#define ERRO_VAR_ALREADY_EXIST -1
#define ERRO_VAR_DONT_EXIST -2
#define ERRO_VAR_INVALID_TYPE -3

extern void init();

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

int main()
{
	init();
    initVarMap();
    yyparse();

    return 0; 
}
