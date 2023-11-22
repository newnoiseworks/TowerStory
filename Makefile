play:
	$(GODOT)

godot:
	$(GODOT) -e -w --resolution 1920x1080

test:
ifneq ($(FILE),)
	$(GODOT) -d -s --path . addons/gut/gut_cmdln.gd -gselect=$(FILE) -glog=$(GLOG_SINGLE) $(GARGS)
else ifneq ($(TEST),)
	$(GODOT) -d -s --path . addons/gut/gut_cmdln.gd -gunit_test_name=$(TEST) -glog=$(GLOG_SINGLE) $(GARGS)
else
	$(GODOT) -d -s --path . addons/gut/gut_cmdln.gd $(GARGS)
endif

lsp:
	$(GODOT) -e --no-window

# GODOT ?= /mnt/c/Users/hello/Downloads/Godot_v3.4.4-stable_win64.exe/Godot_v3.4.4-stable_win64.exe
# GODOT ?= /mnt/c/Users/hello/Downloads/Godot_v3.5.1-stable_win64.exe/Godot_v3.5.1-stable_win64.exe
GODOT ?= /Applications/Godot_v4.1.3.app/Contents/MacOS/Godot
GLOG_SINGLE = 3
GARGS ?=
