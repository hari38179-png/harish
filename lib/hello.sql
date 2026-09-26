SET SERVEROUTPUT ON;

DECLARE
    num       NUMBER := &Enter_Number; -- Prompts user for an input number
    factorial NUMBER := 1;
BEGIN
    -- Factorial is only defined for non-negative integers
    IF num < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Factorial is not defined for negative numbers.');
    ELSIF num = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Factorial of 0 is: 1');
    ELSE
        -- Loop from 1 up to the given number
        FOR i IN 1..num LOOP
            factorial := factorial * i;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Factorial of ' || num || ' is: ' || factorial);
    END IF;
END;
/
