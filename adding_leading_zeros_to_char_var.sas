/* This will take a character string that has numeric values with a range up to 20 bytes and lets you add leading zeros so they are all 20 bytes. You would use this instead of the Z format so you don't lose precision when the number is greater than 16 digits. */

DATA A;                                                   
  INPUT STRING $ 1-20;                                    
  STRING=TRIM(REPEAT('0',20-LENGTH(STRING)-1))||STRING;   
  PUT STRING=;                                            
LINES;                                                    
1                                                         
12                                                        
123                                                       
1234                                                      
12345                                                     
123456 
1234567
12345678
;                                                         
run;

/*tiff comment*/
