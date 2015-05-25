#ifndef __COMPILER_H__
#define __COMPILER_H__

typedef struct sEntry *Entry;

typedef struct sEntryFun *EntryFun;

typedef enum eType Type;



int initVarMap();

EntryFun containsFun(char* varName);

Entry containsVar(EntryFun fun, char* varName);

int decFun(Type type,char* funName, Type* args);

void endDecFun();

int decVar(char* varName, int size);

char getScope(char* varName);

int getAddr(char* varName);

#endif