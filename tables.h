
#ifndef TABLES_H
#define TABLES_H

// Literals Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
struct lit_table;
typedef struct lit_table LitTable;

// Creates an empty literal table.
LitTable* create_lit_table();

// Adds the given string to the table without repetitions.
// String 's' is copied internally.
// Returns the index of the string in the table.
int add_literal(LitTable* lt, char* s);

// Returns a pointer to the string stored at index 'i'.
char* get_literal(LitTable* lt, int i);

// Prints the given table to stdout.
void print_lit_table(LitTable* lt);

// Clear the allocated structure.
void free_lit_table(LitTable* lt);


// Symbols Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
// This table only stores the variable name and the declaration line.
struct sym_table;
typedef struct sym_table SymTable;

// Creates an empty symbol table.
SymTable* create_sym_table();

// Adds a fresh var to the table.
// No check is made by this function, so make sure to call 'lookup_var' first.
// Returns the index where the variable was inserted.
int add_var(SymTable* st, char* s, int line, int scope);

// Returns the index where the given variable is stored or -1 otherwise.
int lookup_var(SymTable* st, char* s, int currentScope);

// Returns the variable name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_name(SymTable* st, int i);

// Returns the declaration line of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_line(SymTable* st, int i);

// Returns the scope of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_scope(SymTable* st, int i);

// Prints the given table to stdout.
void print_sym_table(SymTable* st);

// Clear the allocated structure.
void free_sym_table(SymTable* st);

// Remove all entries in the table, without freeing it
void clean_sym_table(SymTable* st);

// Functions Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
// This table stores the function name, its arity and the declaration line.
struct func_table;
typedef struct func_table FuncTable;

// Creates an empty function table.
FuncTable* create_func_table();

// Adds a fresh function to the table.
// No check is made by this function, so make sure to call 'lookup_func' first.
// Returns the index where the function was inserted.
int add_func(FuncTable* ft, char* s, int arity, int line);

// Returns the index where the given function is stored or -1 otherwise.
int lookup_func(FuncTable* ft, char* s);

// Returns the function name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_func_name(FuncTable* ft, int i);

// Returns the of the function stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_func_arity(FuncTable* ft, int i);

// Returns the declaration line of the function stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_func_line(FuncTable* ft, int i);

// Prints the given table to stdout.
void print_func_table(FuncTable* ft);

// Clear the allocated structure.
void free_func_table(FuncTable* ft);

#endif // TABLES_H

