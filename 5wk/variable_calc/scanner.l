%option noyywrap

%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

/* 패턴 정의: 실수(double) 지원 */
ID      [A-Za-z_][A-Za-z0-9_]*
NUM     ([0-9]+\.[0-9]*|\.[0-9]+|[0-9]+)
WS      [ \t\r]+

%%
"print"     { return T_PRINT; }
"show"      { return T_SHOW; }

{ID}        { yylval.sval = strdup(yytext); return T_ID; }
{NUM}       { yylval.dval = atof(yytext);   return T_NUMBER; }


"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"%"         { return '%'; }
"/"         { return '/'; }
"="         { return '='; }
"("         { return '('; }
")"         { return ')'; }


\n          { return '\n'; }
{WS}        { /* skip */ }

.           { /* 알 수 없는 문자 무시 */ }

%%