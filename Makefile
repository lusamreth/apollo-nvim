# test : 
# 	nvim --headless -u ~/.config/nvim/tests/specs/interface_spec.lua
test: 
	nvim --headless -c "PlenaryBustedDirectory tests/specs/ {minimal_init = 'tests/minimal_init.lua'}"
