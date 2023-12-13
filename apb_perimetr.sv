module apb_perimetr
#(parameter storona_a_ADDR = 4'h0, // адрес числа 1
  parameter storona_b_ADDR = 4'h4, // адрес числа 2
  parameter output_reg_ADDR = 4'h8)  // адрес регистра
(
    input wire PWRITE,            // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
    input wire PCLK,              // сигнал синхронизации
    input wire PSEL,              // сигнал выбора переферии 
    input wire [31:0] PADDR,      // Адрес регистра
    input wire [31:0] PWDATA,     // Данные для записи в регистр
    output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
    input wire PENABLE,           // сигнал разрешения
    output reg PREADY = 0         // сигнал готовности (флаг того, что всё сделано успешно)
);



reg [31:0] storona_a = 0;  // регистр с длинной стороны a
reg [31:0] storona_b = 0;  // регистр с длинной стороны b
reg [31:0] output_reg = 0; // выходной регистр

always @(posedge PCLK) 
begin
    if (PSEL && !PWRITE && PENABLE) // Чтение из регистров 
     begin
        case(PADDR)
         4'h0: PRDATA <= storona_a;  // чтение по адресу регистра стороны а
         4'h4: PRDATA <= storona_b;  // чтение по адресу регистра стороны b
         4'h8: PRDATA <= output_reg; // чтение по адресу выходного регистра
        endcase
        PREADY <= 1'd1; // поднимаем флаг заверешения операции
     end

     else if(PSEL && PWRITE && PENABLE) // запись 
     begin
        case(PADDR)
         storona_a_ADDR: storona_a <= PWDATA; // запись по адресу регистра storona_a
         storona_b_ADDR: storona_b <= PWDATA; // запись по адресу регистра storona_b
        endcase
        PREADY <= 1'd1;    // поднимаем флаг заверешения операции

     end
   
   if (PREADY) // сбрасываем PREADY после выполнения записи или чтения
    begin
      PREADY <= !PREADY;
    end 
  end


always @(storona_a or storona_b) begin // вычисление значения 
 
   output_reg <= 2*(storona_a + storona_b);
  
end

//iverilog -g2012 -o apb_perimetr.vvp apb_perimetr_tb.sv
//vvp apb_perimetr.vvp
endmodule