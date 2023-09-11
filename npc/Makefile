all:
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."
	bear -- verilator --cc --exe --build -j 0 -Wall csrc/main.cpp vsrc/example.v

include ../Makefile
