
Expression Services
================================================

Overview
------------
This service has methods to retrieve data and metadata for expression samples.  
There are also methods to do comparisons (custom, vs default, vs average of samples), 
get top changers and get on off calls.
There are at least 30 functions.
Look at docs/ExpressionServices.html for more information.
The file jb_tests/expression_service_test is set up for easy playing with functions, 
see datadumps and quick switches between starman and plackup.

Author
----------------
Jason Baumohl LBL (jkbaumohl@lbl.gov)

Log
-----------------
1 - Initial Release candidate has its data stored in the expression database on DB1.  
In the future the data may be moved into the CDS

Special deployment instructions
----------
* The Expression service is currently only supported for server deployment in a linux environment.
* follow the standard KBase deployment and testing procedures

Starting and Stopping the service
-----------------
* Go to ExpressionService directory : cd /kb/deployment/services/ExpressionServices
* Export Expression Services : export KB_SERVICE_NAME=ExpressionServices
* export deploy.cfg file : export KB_DEPLOYMENT_CONFIG=/kb/dev_container/modules/expression/deploy.cfg 
* Start Service : ./start_service   or  * Stop Service : ./stop_service

