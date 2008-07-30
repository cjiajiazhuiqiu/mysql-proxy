---
-- test the proxy.auto-config module
--
-- 

local tests      = require("proxy.test")
local command    = require("proxy.commands")
tests.ProxyBaseTest.setDefaultScope()

-- file under test
local tokenizer = require("proxy.tokenizer")

TestScript = tests.ProxyBaseTest:new()

function TestScript:setUp()
	proxy.global.config.test = { }
end

function TestScript:testNormalize()
	local cmd = command.parse(string.char(proxy.COM_QUERY) .. "SET GLOBAL unknown.unknown = 1")

	local tokens = tokenizer.tokenize(cmd.query);
	local norm_query = tokenizer.normalize(tokens)

	assertEquals(norm_query, "SET `GLOBAL` `unknown` . `unknown` = ? ")
end

---
-- test if we can access the fields step-by-step and out-of-range
function TestScript:testFields()
	local cmd = command.parse(string.char(proxy.COM_QUERY) .. "FOO BAR")

	local tokens = tokenizer.tokenize(cmd.query);

	assertEquals(tokens[0], nil)
	assertEquals(tokens[1].text, "FOO")
	assertEquals(tokens[2].text, "BAR")
	assertEquals(tokens[3], nil)
end

---
-- test if empty -- comments are detected
function TestScript:testComments()
	local cmd = command.parse(string.char(proxy.COM_QUERY) .. "--\nSELECT 1\n")

	local tokens = tokenizer.tokenize(cmd.query)
	
	assertEquals(tokens[1].token_name, "TK_COMMENT")
	assertEquals(tokens[1].text, "")
	assertEquals(tokens[2].token_name, "TK_SQL_SELECT")
	assertEquals(tokens[2].text, "SELECT")
	assertEquals(tokens[3].token_name, "TK_INTEGER")
	assertEquals(tokens[3].text, "1")
end



---
-- the test suite runner

local suite = tests.Suite:new({ result = tests.Result:new()})

suite:run()
suite.result:print()
return suite:exit_code()
