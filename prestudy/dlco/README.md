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


## lab3 加法器和 ALU


review of coding
- 原码: 用最高位表示符号位, 其他位存放该数的二进制的绝对值
  - 算术麻烦, 加减都需要讨论符号, +0 -0 问题
- 反码: 正数的反码还是等于原码; 负数的反码就是它的原码除符号位外, 按位取反
  - +0 -0 问题, 负数加法问题
- 补码: 正数的补码等于它的原码; 负数的补码等于反码+1 (or: raw-2^n)
  - `0~2^{n-1}-1`, `-2^n~-1`
  - ~b + 1 =? ~(b_b + 1) + 1
  - 原码 + 反码 + 1 -> 0

adder
```verilog
input  [n-1:0]  in_x, in_y;
output [n-1:0]  out_s;

assign {out_c, out_s} = in_x + in_y;
assign overflow = (in_x[n-1] == in_y[n-1]) && (out_s[n-1] != in_x[n-1]);
```


full adder (unsigned + signed)
- 由于补码的优越性, signed adder 和 unsinged adder 可以用同一个结构实现
```verilog
module adder_4bit(
  output [3:0] o_s,
  output o_c,
  output overflow,
  input [3:0] i_a,
  input [3:0] i_b,
  input i_c
);

wire c1, c2, s1;
assign {c1, s1} = i_a + i_c;
assign {c2, o_s} = s1 + i_b;
assign out_c = c1 | c2;
assign overflow = (i_a[3] == i_b[3]) && (o_s[3] != i_a[3]);
endmodule
```

suber
- 再次由于补码的优越性, suber 用 adder 实现
```verilog
// A - B = A + (-B) = A + ~B + 1
module suber_4bit (
  output [3:0] o_s,
  output o_c,
  input [3:0] i_a,
  input [3:0] b,
  input i_c
);

endmodule
```

e.g. 11111111 + 11111111 results in 111111110
- Carry_Flag set
- Sign_Flag set
- Overflow_Flag clear


suber 的 b 要先取反再 + 1, 不然 cf 有问题
- <https://en.wikipedia.org/wiki/Carry_flag>
- 这里用 subtraction with carry
```verilog
// 0 - 0 -> 0 + ((15 + 1) % 16)

// 15 - 1 -> 15 + ((14 + 1) % 16)
// 1 - 1 -> 1 + ((15 + 1) % 16)
assign t_add_Cin =( {n{Cin}}^B )+ Cin;
assign { Carry, Result } = A + t_add_Cin;
assign Overflow = (A[n-1] == t_add_Cin[n-1]) && (Result [n-1] != A[n-1]);
```

### 实现一个带有逻辑运算的简单 ALU

![img:lab3-alu](https://i.imgur.com/Y65xC9k.png)


## lab6 移位寄存器及桶形寄存器

移位寄存器
```verilog
Q <= {Q[0],Q[7:1]}; // rot right
Q <= {Q[7],Q[7:1]}; // arith right
```

降频
```verilog
always@(posedge clk) begin
  if (count == 0) begin
    // do something
  end
  count <= (count >= 5000000 ? 32'b0 : count + 1);
end
```
```verilog
module slower(
  output reg o_clk,
  input i_clk
);

reg [31:0] count;
always@(i_clk) begin
  if (count == 0) begin
    case(o_clk)
      1'b0: o_clk = 1'b1;
      1'b1: o_clk = 1'b0;
    endcase
  end
  count <= (count >= 5000000)? 32'b0: count + 1;
end
endmodule
```


桶形移位器
- <https://en.wikipedia.org/wiki/Barrel_shifter>
- A barrel shifter is often used to shift and rotate n-bits in modern microprocessors, typically within a single clock cycle

二选一实现单向移位 (arith/logic)
```
 int1  = IN       , if S[2] == 0
       = IN   << 4, if S[2] == 1
 int2  = int1     , if S[1] == 0
       = int1 << 2, if S[1] == 1
 OUT   = int2     , if S[0] == 0
       = int2 << 1, if S[0] == 1
```

四选一双向移位 (arith/logic)
![img:mux41](https://i.imgur.com/FOmfUd0.png)

### 利用移位寄存器实现伪随机数发生器

![img:lfsr](https://i.imgur.com/PJ8cDAr.png)

## lab7 状态机及键盘输入

FSM
- Moore: 输出信号只与有限状态机的当前状态有关, 输入信号的当前值只会影响到状态机的次态 (输入对输出的影响要到下一个时钟周期才能反映出来)
- Mealy: 输出不仅仅与状态机的当前状态有关, 而且与输入信号的当前值也有关 (输入信号的噪声可能影响到输出的信号)

简单状态机, 检测连续四个相同 bit
```verilog
module FSM_bin
(
  input clk, in, reset,
  output reg out
);

parameter[3:0] S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7, S8 = 8;

wire [3:0] state_next, state_cur;
wire state_wen;

SimReg#(4,0) state(clk, reset, state_next, state_cur, state_wen);

assign state_wen = 1;

MuxKeyWithDefault#(9, 4, 1) outMux(.out(out), .key(state_cur), .default_out(0), .lut({
  S0, 1'b0,
  S1, 1'b0,
  S2, 1'b0,
  S3, 1'b0,
  S4, 1'b1,
  S5, 1'b0,
  S6, 1'b0,
  S7, 1'b0,
  S8, 1'b1
}));

MuxKeyWithDefault#(9, 4, 4) stateMux(.out(state_next), .key(state_cur), .default_out(S0), .lut({
  S0, in ? S5 : S1,
  S1, in ? S5 : S2,
  S2, in ? S5 : S3,
  S3, in ? S5 : S4,
  S4, in ? S5 : S4,
  S5, in ? S6 : S1,
  S6, in ? S7 : S1,
  S7, in ? S8 : S1,
  S8, in ? S8 : S1
}));

endmodulem
```

FSM encoding
- ordered binary
- one-hot (FPGA)
- gray code (CPLD)


PS/2 标准
- ps2_clk & ps2_dat
- 协议数据帧: 按键或松开时, 键盘以每帧 11 位的格式串行传送数据给主机, 依次如下
  - 1bit 开始位(逻辑0)
  - 8bit 位数据位(低位在前)
  - 1bit 奇偶校验位(奇校验)
  - 1bit 停止位(逻辑1)
- 扫描码: 单个/多个数据帧
  - 通码(Make Code): 按下 W -> 1D 1D 1D ...
  - 断码(Break Code): 松开 W -> F0 1D
![img:makecode](https://i.imgur.com/YKOjmfG.png)

verilog: task, function
- 增加代码可读性和重复使用性
- function: 描述组合逻辑, 只能有一个返回值, 内部不能包含时序控制
- task: 类似 procedure, 执行一段 verilog 代码, task 中可以有任意数量的输入和输出, task 也可以包含时序控制


在键盘控制器ready信号为1的情况下读取键盘数据，确认读取完毕后将nextdata_n置零 一个周期 


### 实现单个按键的ASCII码显示
- 七段数码管低两位显示当前按键的键码, 中间两位显示对应的 ASCII 码 (转换可以考虑自行设计一个ROM并初始化)
- 当按键松开时, 七段数码管的低四位全灭.
- 七段数码管的高两位显示按键的总次数. 按住不放只算一次按键. 只考虑顺序按下和放开的情况, 不考虑同时按多个键的情况.

NVBoard 提供了物理键盘输出的引脚, 只需要将引脚信号转译即可.



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

lab6
```
"我想要只干净的茶杯, "帽匠插嘴说, "咱们全部挪动一下位子吧!

说着, 他就挪了一个地方, 睡鼠紧随其后, 三月兔就挪到了睡鼠的位子上, 爱丽丝也只好很不情愿地坐到了三月兔的位子上. 这次挪动唯一得到好位子的是帽匠, 爱丽丝的位子比以前差了, 因为刚才三月兔把牛奶打翻在位子上了.

— 《爱丽丝漫游奇境记》 刘易斯·卡罗尔
```


lab7
```
We know the state of the system if we know the sequence of symbols on the tape, which of these are observed by the computer (possibly with a special order), and the state of mind of the computer.

—"On Computable Numbers, with an Application to the Entscheidungsproblem", A. M. Turing
```
