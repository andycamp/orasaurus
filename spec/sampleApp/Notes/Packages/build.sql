
SET SERVEROUTPUT ON
SET DEFINE OFF
SPOOL build.sql.log

PROMPT
PROMPT *****************************GETTING STARTED************************
PROMPT
/
BEGIN DBMS_OUTPUT.PUT_LINE( 'BEGIN TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/

PROMPT ***** pkg_note_comments.pkg *****
@pkg_note_comments.pkg;
SHOW ERRORS
PROMPT ***** pkg_note_tags.pkg *****
@pkg_note_tags.pkg;
SHOW ERRORS
PROMPT ***** pkg_notebooks.pkg *****
@pkg_notebooks.pkg;
SHOW ERRORS
PROMPT ***** pkg_notes.pkg *****
@pkg_notes.pkg;
SHOW ERRORS

BEGIN DBMS_OUTPUT.PUT_LINE( 'END TIME: '||TO_CHAR( SYSDATE, 'MM/DD/YYYY HH:MI:SS' ) ); END;
/
PROMPT
PROMPT *******************************FINISHED*******************************
PROMPT


EXIT
/
    