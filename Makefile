play:
	$(GODOT)

godot:
	$(GODOT) -e

test:
ifeq ($(origin FILE),undefined)
	$(GODOT) -s addons/gut/gut_cmdln.gd --path .
else
	$(GODOT) -s addons/gut/gut_cmdln.gd --path . -gselect=$(FILE)
endif

lsp:
	$(GODOT) -e --no-window

GODOT=/mnt/c/Users/hello/Downloads/Godot_v3.4.4-stable_win64.exe/Godot_v3.4.4-stable_win64.exe
