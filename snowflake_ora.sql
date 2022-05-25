/*0~4095 SEQUENCE*/
CREATE SEQUENCE  SEQ_SNOWFLAKE  MINVALUE 0 MAXVALUE 4095 INCREMENT BY 1 START WITH 40 CACHE 20 NOORDER  CYCLE  NOKEEP  NOSCALE  GLOBAL;

/******************************************/
/*Snowflake ID generation*/
/******************************************/
CREATE OR REPLACE FUNCTION GENERATE_SNOWFLAKE_ID RETURN NUMBER AS 
BEGIN
  DECLARE
  v_currentTime Number;
  --(2021-07-01 00:00) 
  v_epoch number:=1625068800000;
  v_x number;
  v_y number;
  v_result number;
  
  v_sequence number;
  begin
    select extract(DAY FROM(systimestamp - to_timestamp('1970-01-01',
                                                                     'YYYY-MM-DD'))) * 1000 * 60 * 60 * 24 +
                            to_number(to_char(sys_extract_utc(systimestamp),
                                              'SSSSSFF3')) into v_currentTime from dual;
                                 
    --currentMillis - EPOCH << 22           
    v_x := (v_currentTime - v_epoch) * power(2,22); 
    
    --workerId << 12,  workid 512
    v_y :=  512 * power(2, 12);
    
    v_sequence := seq_snowflake.nextval;
    
    --x | y;
    --BITOR(x,y) = (x + y) - BITAND(x, y);
    v_x := v_x + v_y - bitand(v_x, v_y);
    v_result := v_x + v_sequence - bitand(v_x, v_sequence);
    RETURN v_result;                           
  end;
END GENERATE_SNOWFLAKE_ID;
/
