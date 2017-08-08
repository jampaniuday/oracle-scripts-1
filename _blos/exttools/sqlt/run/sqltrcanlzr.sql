SPO sqltrcanlzr_error.log;
@@sqltcommon1.sql
REM $Header: 224270.1 sqltrcanlzr.sql 11.4.5.0 2012/11/21 carlos.sierra $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM   mauro.pagano@oracle.com
REM
REM SCRIPT
REM   sqltrcanlzr.sql
REM
REM DESCRIPTION
REM   This script parses a sql trace file generated by event 10046
REM   levels 1, 4, 8 or 12. Then it produces a comprehensive report
REM   which includes top sql and sql genealogy according to the sql
REM   statements found in the trace provided.
REM
REM PARAMETERS
REM   1. Trace file name on UDUMP.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as application user that generated
REM      trace to be analyzed
REM   2. Execute script sqltrcanlzr.sql passing name of trace file or
REM      the name of the text file that contains multiple traces (one
REM      per line).
REM
REM EXAMPLES
REM   # cd sqlt/run
REM   # sqlplus [apps user]
REM   SQL> start sqltrcanlzr.sql [name of your trace file]
REM   SQL> start sqltrcanlzr.sql largesql.trc  <== your trace file
REM   SQL> start sqltrcanlzr.sql control_file.txt  <== your text file
REM   Notice that a single file must end with ".trc" while a control
REM   file must end with something else like ".txt".
REM
REM NOTES
REM   1. For best results, use Trace Analyzer in the same system
REM      where the trace was generated, and connected as the same
REM      user that generated the trace.
REM   2. To analyze multiple files, create a text file that contains
REM      the names of the trace files to be analyzed, and provide
REM      this filename as the inline parameter to the Trace Analyzer.
REM      This small text file with names of traces (one per line),
REM      should also be located in the the UDUMP directory.
REM   3. For possible errors see sqltrcanlzr_error.log generated
REM      under the SQL*Plus default directory.
REM
@@sqltcommon2.sql
PRO Parameter 1:
PRO Trace Filename or control_file.txt (required)
PRO
DEF input_filename = ^1;
PRO
PRO Value passed:
PRO TRACE_FILENAME: ^^input_filename.
PRO
EXEC DBMS_APPLICATION_INFO.SET_MODULE('sqltrcanlzr', 'script');
PRO
PRO Analyzing ^^input_filename.
PRO
SET TERM OFF HEA ON LIN 2000 PAGES 1000 TRIMS ON TI OFF TIMI OFF;
@@sqltcommon4.sql
EXEC ^^tool_administer_schema..trca$p.set_nls;
EXEC ^^tool_administer_schema..trca$g.general_initialization;
VAR v_tool_execution_id NUMBER;
EXEC :v_tool_execution_id := ^^tool_administer_schema..trca$p.get_tool_execution_id;
COL tool_execution_id NEW_V tool_execution_id FOR A17;
SELECT TO_CHAR(:v_tool_execution_id) tool_execution_id FROM DUAL;
PRO In case of unexpected termination, review file
PRO trca_e^^tool_execution_id..log from output directory
SET TERM ON;
PRO To monitor progress, login into another session and execute:
PRO SQL> SELECT * FROM ^^tool_administer_schema..trca$_log_v;;
PRO
PRO ... analyzing trace(s) ...
PRO
SET TERM ON ECHO OFF VER OFF;
EXEC ^^tool_administer_schema..trca$i.trcanlzr(p_file_name => '^^input_filename.', x_tool_execution_id => :v_tool_execution_id);
SET TERM OFF;
COL trace_file_name NEW_V trace_file_name FOR A640;
SELECT ^^tool_administer_schema..trca$g.get_1st_trace_path_n_name trace_file_name FROM DUAL;
SET TERM ON;
PRO
PRO
PRO Trace Analyzer completed.
PRO Review first sqltrcanlzr_error.log file for possible fatal errors.
PRO Review next trca_e^^tool_execution_id..log for parsing messages and totals.
PRO
PRO Copying now generated files into local directory
PRO
SET TERM OFF ECHO OFF FEED OFF FLU OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 SHOW OFF SQLC MIX TAB OFF TRIMS ON VER OFF TI OFF TIMI OFF ARRAY 100 SQLP SQL> BLO . RECSEP OFF APPI OFF SERVEROUT ON SIZE 1000000 FOR TRU;
SET SERVEROUT ON SIZE UNL;
COL column_value FOR A2000;
WHENEVER OSERROR CONTINUE;
WHENEVER SQLERROR CONTINUE;
PRO No fatal errors!
SPO trca_e^^tool_execution_id..txt;
SELECT column_value FROM TABLE(^^tool_administer_schema..trca$g.display_file(:v_tool_execution_id, 'TEXT'));
SPO trca_e^^tool_execution_id..html;
SELECT column_value FROM TABLE(^^tool_administer_schema..trca$g.display_file(:v_tool_execution_id, 'HTML'));
SPO trca_e^^tool_execution_id..log;
SELECT column_value FROM TABLE(^^tool_administer_schema..trca$g.display_file(:v_tool_execution_id, 'LOG'));
SPO OFF;
HOS tkprof ^^trace_file_name. trca_e^^tool_execution_id._nosort.tkprof
HOS tkprof ^^trace_file_name. trca_e^^tool_execution_id._sort.tkprof sort=prsela exeela fchela
HOS zip -m trca_e^^tool_execution_id. trca_e^^tool_execution_id.* sqltrcanlzr_error.log
HOS zip -d trca_e^^tool_execution_id. sqltrcanlzr_error.log
--HOS unzip -l trca_e^^tool_execution_id.
SET TERM ON;
PRO
PRO File trca_e^^tool_execution_id..zip has been created.
@@sqltcommon9.sql
PRO SQLTRCANLZR completed.