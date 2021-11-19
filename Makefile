test:
	nvim --headless --noplugin -u tests/minimal.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.lua'}"
test-head:
	nvim --noplugin -u tests/minimal.lua
watch: 
	onchange "./lua/**/*.lua" -- make run
watch-test:
	onchange "./**/*.(lua|scm)" -- make test

