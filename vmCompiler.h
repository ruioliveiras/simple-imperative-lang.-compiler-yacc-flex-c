#ifndef __VMCOMPILER_H__
#define __VMCOMPILER_H__

typedef struct sEntryVar *EntryVar;

typedef struct sEntryFun *EntryFun;

typedef enum eType{_VOID,_INTS,_INTA} Type;


typedef struct sAddr{
    int addr;
    char scope;
    Type type;
} Addr;


int initVarMap();

EntryFun containsFun(char* varName);

EntryVar containsVar(EntryFun fun, char* varName);

int decVar(char* varName, int size);

int decFun(Type type, char* funName);

int decAddFunArg(Type type, char* name);

void decFunArgRefresh();

void endDecFun();

int getFunRetAddr();

int getFunNArgs();

Addr getAddr(char* varName);

#endif