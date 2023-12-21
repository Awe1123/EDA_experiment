module N_bitcomparator       //N: you can just set it from 1 ~ 16;
(
    input   [3:0]    A,
    input   [3:0]    B,
    output  wire      equate
);

assign equate = (A[3:0] == B[3:0]);

endmodule 