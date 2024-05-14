--------------------------------------------------------------------------------
--      Purpose: Create User account in PMX
--      Written By: Christopher DeAngelis
--      Original Create Date: 09-JAN-2023
--      Revision: 1.0
--------------------------------------------------------------------------------

DECLARE
  A_ID varchar2(30);
  A_DEPARTMENT varchar2(30);
  A_COMMENTS varchar2(100);
  A_EMAIL varchar2(30);
  A_FAX varchar2(30);
  A_LOGINFROM date;
  A_LOGINTO date;
  A_PASSWORD date;
  A_LOGINNAME varchar2(30);
  A_NAME varchar2(30);
  A_NUMBER varchar2(30);
  A_SITE_HOME varchar2(30);
  A_PHONENUMBER varchar2(30);
  A_TYPE varchar2(30);
  A_INVALID varchar2(30);
  A_USE_ACTIVE_DIRECTORY_ varchar2(30);
  
BEGIN
--define user parameters here--
A_ID := NULL;
A_DEPARTMENT := '6';
A_COMMENTS := 'TEST1';
A_EMAIL := 'contact@google.com';
A_FAX := '+1/(0)555/5555-888';
A_LOGINFROM := to_date(SYSDATE, 'dd.mm.rrrr hh24:mi:ss');
A_LOGINTO := to_date('31.12.2999 00:00:00', 'dd.mm.yyyy hh24:mi:ss');
A_PASSWORD := to_date(SYSDATE, 'dd.mm.rrrr hh24:mi:ss');
A_LOGINNAME := 'TEST1';
A_NAME := 'TEST1';
A_NUMBER := 'TEST1';
A_SITE_HOME := '1';
A_PHONENUMBER := '+1/(0)555/5555-888';
A_TYPE := '0';
A_INVALID := '0';
A_USE_ACTIVE_DIRECTORY_ := '1';

--Creates User Account based on given parameters
INSERT INTO USER (ID, DEPARTMENT, COMMENTS, EMAIL, FAX, LOGINFROM, LOGINTO, PASSWORD, LOGINNAME, NAME, NUMBER, SITE_HOME, PHONENUMBER, TYPE, INVALID, USE_ACTIVE_DIRECTORY_)
VALUES (A_ID, A_DEPARTMENT, A_COMMENTS, A_EMAIL, A_FAX, A_LOGINFROM, A_LOGINTO, A_PASSWORD, A_LOGINNAME, A_NAME, A_NUMBER, A_SITE_HOME, A_PHONENUMBER, A_TYPE, A_INVALID, A_USE_ACTIVE_DIRECTORY_);

END;