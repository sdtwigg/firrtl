; RUN: firrtl -i %s -o %s.v -X verilog -p ct 2>&1 | tee %s.out | FileCheck %s

;CHECK: Infer Types
circuit top :
   module subtracter :
      input x : UInt
      input y : UInt
      output z : UInt
      z <= tail(sub(x, y),1)
      ;CHECK: z@<t:UInt> <= tail(sub(x@<t:UInt>, y@<t:UInt>)@<t:SInt>, 1)@<t:UInt>   
   module gcd :
      input a : UInt<16>
      input b : UInt<16>
      input e : UInt<1>
      input clk : Clock
      input reset : UInt<1>
      output z : UInt<16>
      reg x : UInt,clk with :
         reset => (reset,UInt(0))
      reg y : UInt,clk with :
         reset => (reset,UInt(42))
      ; CHECK: reg x : UInt, clk@<t:Clock> with :
         ;CHECK:reset => (reset@<t:UInt>, UInt<1>("h0")@<t:UInt>)
      when gt(x, y) :
      ;CHECK: when gt(x@<t:UInt>, y@<t:UInt>)@<t:UInt> :
         inst s of subtracter
         ;CHECK: inst s of subtracter : {flip x : UInt, flip y : UInt,  z : UInt}
         s.x <= x
         s.y <= y
         x <= s.z
         ;CHECK: s@<t:{flip x : UInt, flip y : UInt,  z : UInt}>.x@<t:UInt> <= x@<t:UInt>
         ;CHECK: s@<t:{flip x : UInt, flip y : UInt,  z : UInt}>.y@<t:UInt> <= y@<t:UInt>
         ;CHECK: x@<t:UInt> <= s@<t:{flip x : UInt, flip y : UInt,  z : UInt}>.z@<t:UInt>      
      else :
         inst s2 of subtracter
         s2.x <= x
         s2.y <= y
         y <= s2.z
      when e :
         x <= a
         y <= b
      z <= x
   module top :
      input a : UInt<16>
      input b : UInt<16>
      input clk : Clock
      input reset : UInt<1>
      output z : UInt
      inst i of gcd
      i.a <= a
      i.b <= b
      i.clk <= clk
      i.reset <= reset
      i.e <= UInt(1)
      z <= i.z

; CHECK: Finished Infer Types
