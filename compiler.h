#ifndef __COMPILER_H__
#define __COMPILER_H__

typedef struct sEntryVar *EntryVar;

typedef struct sEntryFun *EntryFun;

typedef enum eType Type;



int initVarMap();

EntryFun containsFun(char* varName);

EntryVar containsVar(EntryFun fun, char* varName);

int decVar(char* varName, int size);

int decFun(Type type, char* funName, Type* args);

void endDecFun();

char getScope(char* varName);

int getAddr(char* varName);

#endif