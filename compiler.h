#ifndef __COMPILER_H__
#define __COMPILER_H__

#define OK 0
#define ERRO_VAR_ALREADY_EXIST -1
#define ERRO_VAR_DONT_EXIST -2
#define ERRO_VAR_INVALID_TYPE -3


typedef enum eType{_INTS,_INTA} Type;
typedef struct sEntry *entry;


int poc_init();
int poc_dec_var(Type type, char* name, int size);
int poc_dec_func(Type type, char* name);

int poc_for_header();


int poc_exp_minus();
int poc_exp_plus();
int poc_exp_mult();
int poc_exp_div();
int poc_exp_rest();
int poc_exp_num(int val);
int poc_exp_var(char* name);

int initVarMap();
int decVar(char* varName, int size);
entry containsVar(char* varName);



#endif