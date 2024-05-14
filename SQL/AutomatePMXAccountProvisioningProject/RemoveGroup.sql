--------------------------------------------------------------------------------
--      Purpose: Remove Group from user account in PMX
--      Written By: Christopher DeAngelis
--      Original Create Date: 09-JAN-2023
--      Revision: 1.0
--------------------------------------------------------------------------------

DECLARE
  GROUP_NUMBER varchar2(10);
  USER_NUMBER varchar2(10);
  A_USER_GROUP_ID varchar2(30);
  A_USER_GROUP_MEMBERSHIP_ID varchar2(30);
--PERMID represents the permissions record ID in groupmembertable
  PERMID varchar2(10);
  
BEGIN
--define Group and User ID here--  
  GROUP_NUMBER := 'GroupID';
  USER_NUMBER := 'UserID';
  
  
--assigns ID value for needed Group
  SELECT ID INTO A_USER_GROUP_ID FROM USER
  WHERE NUMBER = GROUP_NUMBER;

--assigns ID value for needed User
  SELECT ID INTO A_USER_GROUP_MEMBERSHIP_ID FROM USER
  WHERE NUMBER = USER_NUMBER;
  
--finds record ID for permission
  SELECT rg.ID INTO PERMID
  FROM GROUPMEMBERTABLE rg
  LEFT JOIN USER a
  ON rg.USER_GROUP = a.ID
  OR rg.USER_MEMBERSHIP = a.ID
  WHERE a.ID = A_USER_GROUP_MEMBERSHIP_ID
  AND rg.USER_GROUP = A_USER_GROUP_ID
  AND rg.USER_MEMBERSHIP = A_USER_GROUP_MEMBERSHIP_ID;

--Deletes Group permissions record from db
DELETE GROUPMEMBERTABLE
WHERE ID = PERMID;

END;