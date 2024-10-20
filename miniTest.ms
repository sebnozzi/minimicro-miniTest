import "stringUtil"

// PUBLIC API
// These functions are available after importing this module
_public_api = [
// Invoke once tests are defined
"test",
// Numerous assertion functions
"assertEqual", 
"assertTrue",
"assertFalse",
"assertNull",
"assertNotNull",
// Force failure
"fail"]

// These make it possible to run actions before/after each test
_lifecycle_functions = [
"beforeEach",
"afterEach"]

// Prefix used to identify individual test-functions
_test_function_prefix = "test_"

// === RUNNER

runner = {}
runner.lastTestFailed = null
runner.beforeEach = null
runner.afterEach = null

test = function
	clear
	setupHooks
	printColor color.silver, "Running tests ..."
	for testName in testsToRun
		// Select the test
		test_fn = globals[testName]
		printColor color.silver, "- ", ""
		printColor color.white, testName, ""
		printColor color.silver, " ... ", ""
		runner.lastTestFailed = false
		// Invoke beforeEach
		if runner.beforeEach then runner.beforeEach
		// Invoke the test
		test_fn()
		if not runner.lastTestFailed then
			printColor color.lime, "PASS!"
		end if
		// Invoke afterEach
		if runner.afterEach then runner.afterEach
	end for
end function

// === ASSERTS

assertEqual = function(actual, expected, note)
	if actual == expected then return
	msg = "Assert failed"
	if note != null then msg = msg + " (" + note + ")"
	msg = msg + ": expected `" + expected + "`, but got `" + actual + "`"
	fail msg
end function

assertTrue = function(condition, desc)
	if condition then return
	msg = "Assert failed"
	if desc != null then msg = msg + ": " + desc
	fail msg
end function

assertFalse = function(condition, desc)
	if not condition then return
	msg = "Not false"
	if desc != null then msg = msg + ": " + desc
	fail msg
end function

assertNotNull = function(value, desc)
	if value != null then return
	msg = "Null value"
	if desc != null then msg = msg + ": " + desc
	fail msg
end function

assertNull = function(value, desc)
	if value == null then return
	msg = "Not null value"
	if desc != null then msg = msg + ": " + desc
	fail msg
end function

// === FAILURE

fail = function(errMsg)
	callStackLineText = "(current program) line "
	runner.lastTestFailed = true
	printColor color.red, "FAIL!"
	printColor color.pink, errMsg + " (line: " + findFailureLineNr + ")"
end function

// === PRIVATE

printColor = function(colr, msg, delimiter=null)
	prev_color = text.color
	prev_delim = text.delimiter
	
	text.color = colr
	
	if delimiter == null then
		text.delimiter = char(13)
	else
		text.delimiter = delimiter
	end if
	
	print msg
	
	text.color = prev_color
	text.delimiter = prev_delim
end function

// Try to find the line-nr where a test-failure took place
// For that, analyze the call-stack and extract the line number
// of the first entry of the "current[ly] [running] program",
// which will be the one where the tests run (not where the
// assertion functions are defined).
findFailureLineNr = function
	callStackLineText = "(current program) line "
	for line in stackTrace
		// Try to extract the first "current program" line number
		callStackLineIdx = line.indexOf(callStackLineText)
		if callStackLineIdx != null then
			callStackLineIdx += len(callStackLineText)
			return line[callStackLineIdx:]
		end if
	end for
	return "unknown"
end function

testsToRun = function
	test_names = []
	for key in globals.indexes
		if key.startsWith("test_") then
			test_names.insert 0, key
		end if
	end for
	return test_names
end function

setupHooks = function
	for symbol in _lifecycle_functions
		if globals.hasIndex(symbol) then
			runner[symbol] = @globals[symbol]
		end if
	end for
end function

// === RUN AT IMPORT

// Remove possible existing tests.
// The invoking code will (re)define tests as needed.
for key in globals.indexes
	if key.indexOf(_test_function_prefix) == 0 then 
		globals.remove key
	end if
end for

// Export API symbols to outer scope
for symbol in _public_api
	outer[symbol] = locals[symbol]
end for
