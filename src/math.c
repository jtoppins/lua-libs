#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

// 1. Define the C function that Lua will execute
static int mysum(lua_State *L) {
	// Retrieve arguments from the Lua stack
	double a = luaL_checknumber(L, 1);
	double b = luaL_checknumber(L, 2);

	// Push the result back onto the Lua stack
	lua_pushnumber(L, a + b);

	// Return the number of return values (1 value)
	return 1;
}

// 2. Map Lua function names to C function pointers
static const struct luaL_Reg mymodule_funcs[] = {
	{"sum", mysum},
	{NULL, NULL} // Sentinel row to mark the end
};

// 3. Define the entry point function
// Must be named exactly luaopen_<modulename>
int luaopen_dcsext_math(lua_State *L) {
	// Create a new table and register the functions into it
	luaL_register(L, "dcsext_math", mymodule_funcs);
	return 1; // Return the table to Lua
}
