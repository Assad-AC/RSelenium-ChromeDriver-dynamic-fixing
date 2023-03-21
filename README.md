# RSelenium-ChromeDriver-dynamic-fixing

Short description: Simple code and files to pre-empt debugging RSelenium when used with Chrome and without Docker.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Elaboration:

This script and the batch file it comes with aim to address two issues which can make long-term work with RSelenium without the use of Docker cumbersome. 

First, it determines which version of Chrome is installed and extracts string information on the matching Chromedriver. The Chromedriver version which matches is used as the chromever argument for the rsDriver function. The installed Chrome version is determined by reading a log file that is produced after running the batch file found within the zip file in this repository. 

Second, it deletes the license file associated with the version of the Chromedriver which has been selected as matching the version of Chrome installed on the user's device.

These are usually done manually, but the script and batch file aim to automate these matters.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Files in the repository:

The zip file contains the script and the folder directories with the .proj file from which the script can be smoothly run. The script can of course be adapted for different folder directory arrangements. The .bat batch file is also in the zip file, and the R code to call to execute it is found in the script.
