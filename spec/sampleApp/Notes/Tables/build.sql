
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL build.sql.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

PROMPT ***** notebooks.sql *****
@notebooks.sql;
SHOW ERRORS
PROMPT ***** notes.sql *****
@notes.sql;
SHOW ERRORS
PROMPT ***** note_tags.sql *****
@note_tags.sql;
SHOW ERRORS
PROMPT ***** note_comments.sql *****
@note_comments.sql;
SHOW ERRORS

BEGIN DBMS_OUTPUT.PUT_LINE( 'END TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/
PROMPT
PROMPT *******************************FINISHED*******************************
PROMPT


EXIT
/
    