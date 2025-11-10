//to do
---------------------------fixe 1----------------------------------------
logic element=0 when compile fpga cause of dont write enough value to 2D array(2D array readmem from external file.mem) 
example: 2048=2KB , each row contain 4 byte(2048/4=512row) so musr fill out enough value to 512 row
--------------------------------fix 2
LSu fixed
// ❌ SAI: i_reset trong combinational read
always @(i_lsu_addr, ...) begin
    if (i_reset) ...  // Không hợp lý!
end

// ✅ ĐÚNG: Read logic không cần reset
always @(*) begin
    o_ld_data = ...;  // Chỉ phụ thuộc vào address
end
------------------------------------fix 3-------------------------

add default case 
              end
            end
            
            // Reserved
            default:o_ld_data = 32'b0; // Explicit default ;
        endcase
    end

endmodule
----------------------------------fix 4
adđ default case in control unit

    
