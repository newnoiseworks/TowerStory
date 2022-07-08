play:
	$(GODOT)

godot:
	$(GODOT) -e -w --resolution 1920x1080

test:
ifneq ($(FILE),)
	$(GODOT) -s addons/gut/gut_cmdln.gd --path . -gselect=$(FILE) -glog=$(GLOG_SINGLE)
else ifneq ($(TEST),)
	$(GODOT) -s addons/gut/gut_cmdln.gd --path . -gunit_test_name=$(TEST) -glog=$(GLOG_SINGLE)
else
	$(GODOT) -s addons/gut/gut_cmdln.gd --path .
endif

lsp:
	$(GODOT) -e --no-window

GODOT=/mnt/c/Users/hello/Downloads/Godot_v3.4.4-stable_win64.exe/Godot_v3.4.4-stable_win64.exe
GLOG_SINGLE=3
