#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <nvboard.h>
#include <iostream>

void nvboard_bind_all_pins(Vtop *top);

VerilatedContext *contextp = NULL;
VerilatedVcdC *tfp = NULL;

static Vtop *top;

void step_and_dump_wave() {
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init() {
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new Vtop;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("wave.vcd");
  nvboard_bind_all_pins(top);
  nvboard_init();
}

void sim_exit() {
  nvboard_quit();
  step_and_dump_wave();
  tfp->close();
}

int main() {
  sim_init();

  while (1) {
    // std::cout << "loop" << std::endl;
    top->eval();
    nvboard_update();
  }
  sim_exit();
}
