import lupa
from lupa import LuaRuntime
lua = LuaRuntime(unpack_returned_tuples=True)

with open('Tests/Test_UIRenderer.lua', 'r', encoding='utf-8') as f:
    lua_code = f.read()

try:
    lua.execute(lua_code)
except Exception as e:
    print("Python Lua Exception:", e)
