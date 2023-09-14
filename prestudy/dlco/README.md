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




## lab6




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
