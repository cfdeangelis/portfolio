--------------------------------------------------------------------------------
--      Purpose: Add Group to user account in PMX
--      Written By: Christopher DeAngelis
--      Original Create Date: 09-JAN-2023
--      Revision: 1.0
--------------------------------------------------------------------------------

DECLARE
  GROUP_NUMBER varchar2(10);
  USER_NUMBER varchar2(10);
  USER_GROUP_ID varchar2(30);
  USER_GROUP_MEMBERSHIP_ID varchar2(30);
  
BEGIN
--define Group and User ID here--
  GROUP_NUMBER := 'GroupID';
  USER_NUMBER := 'UserID';

--assigns ID value for needed Group
  SELECT ID INTO USER_GROUP_ID FROM USER
  WHERE NUMBER = GROUP_NUMBER;

--assigns ID value for needed User
  SELECT ID INTO USER_GROUP_MEMBERSHIP_ID FROM USER
  WHERE NUMBER = USER_NUMBER;

--Adds Group permissions record to db
INSERT INTO GROUPMEMBERTABLE (USER_GROUP, USER_MEMBERSHIP) VALUES (USER_GROUP_ID, USER_GROUP_MEMBERSHIP_ID);

END;