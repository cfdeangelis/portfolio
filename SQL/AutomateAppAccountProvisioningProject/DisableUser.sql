--------------------------------------------------------------------------------r
--      Purpose: Disable User account in PMX and remove all Group permissions
--      Written By: Christopher DeAngelis
--      Original Create Date: 09-JAN-2023
--      Revision: 1.0
--------------------------------------------------------------------------------

DECLARE
  A_ORIGINALCOMMENTS varchar2(10000);
  A_COMMENTS varchar2(100);
  A_NUMBER varchar2(10);

BEGIN
--define User ID and Comments to add here--
  A_COMMENTS := '	Disabled account per TASK0000';
  A_NUMBER := 'TEST1';

--------------------------------------------------------------------------------
/*DISABLE USER ACCOUNT*/
--set original comments
  SELECT COMMENTS INTO A_ORIGINALCOMMENTS FROM USER
  WHERE NUMBER = A_NUMBER;

--Disables user account per current practices
UPDATE
  USER
SET
  COMMENTS = CONCAT(A_ORIGINALCOMMENTS, A_COMMENTS),
  LOGINFROM = NULL,
  LOGINTO = NULL,
  PASSWORD = NULL
WHERE
  NUMBER = A_NUMBER;

END;