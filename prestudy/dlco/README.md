# nju lab
- <https://nju-projectn.github.io/dlco-lecture-note/index.html>
- <https://pages.hmc.edu/harris/ddca/ddcarv.html>
- <https://hdlbits.01xz.net/wiki/Main_Page>
- <https://verilogoj.ustc.edu.cn/oj/>
- <https://inst.eecs.berkeley.edu/~cs150/fa06/Labs/verilog-ieee.pdf>

FPGA 的主要作用是仿真加速, 而 ysyx 基本上遇不到:
```
FPGA_syn_time + FPGA_impl_time + FPGA_run_time < verilator_compile_time + verilator_run_time
FPGA_syn_time + FPGA_impl_time + FPGA_run_time < verilator_compile_time + verilator_run_time
```


## lab1 选择器

建模方式
- 数据流建模: 画电路
- 结构化建模: 逐层画电路
- 行为建模: 编程, 电路转化为事件队列

行为建模
- 在硬件描述语言中, "执行" 的精确含义是什么?
- 是谁在执行 Verilog 的语句?  是电路, 综合器, 还是其它的?
- if 的条件满足, 就不执行 else 后的语句, 这里的 "不执行" 又是什么意思?  和描述电路有什么联系?
- 有 "并发执行", 又有 "顺序执行", 还有 "任何一个变量发生变化就立即执行", 以及 "在任何情况下都执行", 它们都是如何在设计出来的电路中体现的?


避免锁存器: 保存未被覆盖的情况下输出的过去值, 这一般是不希望出现的情况
- case 语句中建议无论如何保留 default 选项


### 实现一个简单的二位四选一选择器

调用+接线
![img: lab1](https://i.imgur.com/HnkETMI.png)

就是死循环 eval 给人感觉不太好, verilator 并不会自动检测值的变化, `nvboard_update` 也不会自己阻塞住
```cc
  while (1) {
    // std::cout << "loop" << std::endl;
    top->eval();
    nvboard_update();
  }
```

## lab2 译码器和编码器

normally
- decoder: 2^n -> n
- encoder: n -> 2^n

for 循环的 condition 条件表达式必须为常数, 不能是可改变的量

![img: seven-led](https://i.imgur.com/iV6JCZq.png)


了解 casex 和 casez 语句的使用, 思考如何用 casex 语句来完成优先编码器的设计
> 但是 casex, casez 一般是不可综合的, 多用于仿真..
<https://www.runoob.com/w3cnote/verilog-case.html>

### 实现一个 8-3 优先编码器并在七段数码管上显示

数码管是低电平的

开始还想为啥要有个判断是否有输入, 原来是给 bcdseg 用的
```verilog
assign seg_in = enc_ok ? {1'b0, enc_out} : 8;
```
![img: lab2](https://i.imgur.com/AKR4icG.png)


## lab

## Easter eggs

lab1
```
To be, or not to be, that is the question. 
—《哈姆雷特》, 莎士比亚
```

lab2
```
伊吉斯将另一面白色的帆交给领航, 特别交代他在回航的时候, 如果帖修斯平安归来, 就将这面船帆升起来; 要是事与愿违就用黑色的船帆, 等于是悬挂出不幸的信号.
—《希腊罗马名人传》, 普鲁塔克
```

lab3
```
"Six by nine. Forty-two."
"That’s it. That’s all there is."
"I always thought something was fundamentally wrong with the universe."
— "The Restaurant at the End of the Universe",  Douglas Adams
```
