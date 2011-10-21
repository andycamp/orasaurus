
    SET	 SERVEROUTPUT ON
    SET DEFINE OFF
    SPOOL teardown.log
    
    DECLARE
      CURSOR cur_drop_list
      IS
        SELECT *
        FROM USER_OBJECTS
        WHERE OBJECT_NAME IN ( 'CREATE_TEST_USER' )
        AND OBJECT_TYPE != 'PACKAGE BODY';
      x BOOLEAN := FALSE;    
    BEGIN
      DBMS_OUTPUT.PUT_LINE( 'starting work' );
      FOR i IN cur_drop_list LOOP
        x := TRUE;
        BEGIN
          EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name||' CASCADE CONSTRAINTS';
          DBMS_OUTPUT.PUT_LINE( 'DROPPED '||i.object_name );
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE( 'WHILE DROPPING '||i.object_type||' '||i.object_name );
            DBMS_OUTPUT.PUT_LINE( SUBSTR( SQLERRM, 1, 255 ) );
        END;
      END LOOP;
      IF NOT x THEN
        DBMS_OUTPUT.PUT_LINE( 'NOTHING FOUND TO DROP' );
      END IF;
      DBMS_OUTPUT.PUT_LINE( 'completed successfully' );  
    END;
    /
    
    EXIT
    /
    