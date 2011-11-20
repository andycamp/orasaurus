
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL build.sql.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

PROMPT ***** note_comments_seq.sql *****
@note_comments_seq.sql;
SHOW ERRORS
PROMPT ***** notebooks_seq.sql *****
@notebooks_seq.sql;
SHOW ERRORS
PROMPT ***** note_tags_seq.sql *****
@note_tags_seq.sql;
SHOW ERRORS
PROMPT ***** notes_seq.sql *****
@notes_seq.sql;
SHOW ERRORS

BEGIN DBMS_OUTPUT.PUT_LINE( 'END TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/
PROMPT
PROMPT *******************************FINISHED*******************************
PROMPT


EXIT
/
    