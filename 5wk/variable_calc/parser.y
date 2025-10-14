%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* lexer/에러 */
int yylex(void);
void yyerror(const char *s);

/* --- 심볼테이블: 단순 연결리스트 --- */
typedef struct Sym {
  char *name;
  double   value;
  struct Sym *next;
} Sym;

static Sym *symtab = NULL;

static Sym* lookup(const char *name){
  for (Sym *p = symtab; p; p = p->next)
    if (strcmp(p->name, name) == 0) return p;
  return NULL;
}
static double getval(const char *name){
  Sym *s = lookup(name);
  if (!s) {
    fprintf(stderr, "undefined variable: %s\n", name);
    return 0.0;
  }
  return s->value;
}
static void setval(const char *name, double v){
  Sym *s = lookup(name);
  if (!s) {
    s = (Sym*)malloc(sizeof(Sym));
    s->name = strdup(name);
    s->next = symtab;
    symtab = s;
  }
  s->value = v;
}
%}

/* --- 토큰/타입 --- */
%union { double dval; char *sval; }

%token <dval> T_NUMBER
%token <sval> T_ID
%token T_PRINT
%token T_SHOW

%left '+' '-'
%left '*' '/'
%right UMINUS

%type <dval> expr stmt
%start input

%%

/* 줄 단위로 읽고, 줄마다 결과 출력 */
input
  : /* empty */
  | input stmt '\n'          { printf("%.4f\n", $2); }
  | input '\n'               { /* 빈 줄 무시 */ }
  ;

stmt
  : expr                          { $$ = $1; }
  | T_ID '=' expr                 { setval($1, $3); $$ = $3; free($1); }
  | T_PRINT '(' expr ')'        { $$ = $3; }  // print_stmt의 규칙을 직접 가져옴
| T_SHOW '(' expr ')' {
      printf("결과를 출력하겠습니당~\n%.4f 입니당!\n", $3); // $3 값을 직접 출력
      $$ = $3; // 다음 논터미널에 값을 전달만 합니다.
  }
  ;

expr
  : expr '+' expr            { $$ = $1 + $3; }
  | expr '-' expr            { $$ = $1 - $3; }
  | expr '*' expr            { $$ = $1 * $3; }
  | expr '/' expr            { if ($3 == 0.0) { yyerror("division by zero"); $$ = 0.0; } else $$ = $1 / $3; }
  | '-' expr %prec UMINUS    { $$ = -$2; }
  | '(' expr ')'             { $$ = $2; }
  | T_NUMBER                 { $$ = $1; }
  | T_ID                     { $$ = getval($1); free($1); }
  ;

%%

void yyerror(const char *s){ fprintf(stderr, "parse error: %s\n", s); }

int main(void){
  return yyparse();
}
