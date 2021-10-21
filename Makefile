test:
	nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
test-head:
	nvim --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
run: 
	nvim --headless --noplugin -u tests/minimal.vim ./tests/test.js
watch: 
	onchange "./lua/**/*.lua" -- make run
watch-test:
	onchange "./**/*.(lua|scm)" -- make test

