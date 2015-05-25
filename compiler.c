#include "compiler.h"
#include "hashmap.h"
#include <stdlib.h>

static map_t mVarMap;
static map_t mFuncMap;
static int addressCounter;

typedef struct sEntry{
    Type type;
    char *name;
    int memAdr;
} *entry;

int initVarMap()
{
	addressCounter = 0;
	mVarMap = hashmap_new();
	return 0;
}

int decVar(char* varName, int size)
{
	if(containsVar(varName)==NULL)
	{
		entry newVar = (entry) malloc(sizeof(struct sEntry));
		if(size>1)
		{
			newVar->type = _INTA;
		}
		else
		{
			newVar->type = _INTS;
		}
		newVar->name = varName;
		newVar->memAdr = addressCounter;
		addressCounter+=size;

		hashmap_put(mVarMap, varName, (any_t) newVar);

		return OK;
	}
	return ERRO_VAR_ALREADY_EXIST;
}

entry containsVar(char* varName)
{
	entry var = (entry) malloc(sizeof(entry));
	
	if(!(hashmap_get(mVarMap, varName, (any_t) var) == MAP_OK))
		var = NULL;
	return var;	
}

