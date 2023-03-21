#Credit is due to Samer Hijazi for laying the groundwork in showing how to run RSelenium.
#It is also due to the unknown authors of the bash file at Chromium,
#which I only edited to introduce the creation of the log file.

####Load packages####
library(RSelenium)
library(netstat)
library(dplyr)
library(tidyr)
library(readxl)
library(here)
library(readtext)
library(stringr)

####1. Specify directory, depending on file path or use of .proj file####
FilePath_RSeleniumChromverFix <- ""

####2. Determine current version of Chrome installed on device####

#####2.1. Execute batch file to create log file#####
shell.exec(here(FilePath_RSeleniumChromverFix,
                "Batch and log file",
                "getChromeVersion.bat"))

Sys.sleep(0.4)

#####2.2. Move log file to correct folder#####

#Delete log file in correct folder (if present after running this script before)
file.remove(here(FilePath_RSeleniumChromverFix,
                          "Batch and log file",
                          "currentChromeVersion.log"))

#Copy log file to correct folder
file.copy(from = here(FilePath_RSeleniumChromverFix,
                          "currentChromeVersion.log"),

          to = here(FilePath_RSeleniumChromverFix,
                          "Batch and log file",
                          "currentChromeVersion.log"))

#Delete the original log file in the wrong folder
file.remove(here(FilePath_RSeleniumChromverFix,
                          "currentChromeVersion.log"))


#####2.3. Read log file#####
LogFile_w_ChromeVersionOnDevice <-
  readtext::readtext(here(FilePath_RSeleniumChromverFix,
                          "Batch and log file",
                          "currentChromeVersion.log"))

#####2.4. Extract the Chrome version (identified as numerical digits that are delimited by dots which follow REG_SZ#####
LatestChromeVersion <-
  stringr::str_extract(LogFile_w_ChromeVersionOnDevice$text,
                       "(?<=REG_SZ(\\s{1,100}))(\\d+\\.\\d*)+(?=\\n)")


#####2.5. Extract the first digits until the first point delimiter (e.g. 123 from 123.456.78)#####
LatestChromeVersion_FirstDigits <-
  str_extract(LatestChromeVersion, "\\d+(?=\\.)")

ChromeDriverVersionsVec <-
  unlist(binman::list_versions("chromedriver"))

ChromeDriverVersionsVec_FirstDigits <-
  str_extract(ChromeDriverVersionsVec, "\\d+(?=\\.)")

#####2.6. Get the first chromedriver version which corresponds to the Chrome version by matching the first digits of the versions#####

#Subset the vector of chromedriver versions (first digits) by the index of the
#first element in the vector which matches the first digits of the current version of Chrome. 
#This is the chrome driver version to use for Selenium's rsDriver.
SuggestedChromeVer <-
  ChromeDriverVersionsVec[match(LatestChromeVersion_FirstDigits,
                                 ChromeDriverVersionsVec_FirstDigits)]


####3. For the identified version of the chromedriver to use, delete the license file####

#####3.1. Obtain file paths used in Selenium installation#####
RSeleniumFilePaths <- wdman::selenium(retcommand = TRUE)

#####3.2. Extract the filepath to the chromedriver.exe file (for the chromedriver version chosen in section 2.5####
SuggestedChromeDriver_ExeFilePath <-
    str_extract_all(RSeleniumFilePaths, 
                    "(?<=-Dwebdriver.chrome.driver.{0,100})\\w.*.+chromedriver.exe")[1][[1]]

#####3.3. For the chromedriver.exe filepath, replace chromedriver.exe for LICENSE.chromedriver#####

#This round-about way of extracting the license file path was chosen because opting to select it directly caused mis-selection.
#This may have been due to a poor choice of regex on my part.

SuggestedChromeDriver_LicenseFilePath <-
  str_replace(SuggestedChromeDriver_ExeFilePath,
              "(\\d+\\.\\d*)+/chromedriver.exe",
              paste0(SuggestedChromeVer, "/LICENSE.chromedriver"))


#####3.4. Delete LICENSE.chromedriver with the filepath determined above#####
if(file.exists(SuggestedChromeDriver_LicenseFilePath)){
  
  file.remove(SuggestedChromeDriver_LicenseFilePath)
  
}


####4. Locally host Selenium server with SuggestedChromeVer as the chromever argument####
RsDriverObject  <- rsDriver(
  browser = "chrome",
  chromever = SuggestedChromeVer,
  verbose = FALSE,
  port = free_port())  #The choice of port is a personal preference.


#The chromedriver should be launched and active by now.

#Finding the directory where your chromedriver files are if there are further problems:
cat(paste0("If there is an error, the main area to check is: ",
             str_replace_all(str_extract(SuggestedChromeDriver_LicenseFilePath, 
                                     ".*(?=(\\\\\\\\\\d+\\.\\d*)+)"),
                         "(?<=\\S)\\\\\\\\(?=\\S)",
                         "\\\\")))
             

#The directory is usually of the form: C:/Users/USERNAME/AppData/Local/binman/binman_chromedriver/win32/


####Optional: create client object, and proceed with other Selenium business of your choosing####
RemDr <- RsDriverObject$client

RemDr$navigate("https://duckduckgo.com/")

DuckDuckGoMainSearchBar <-
  RemDr$findElement(using = "id",
                    "search_form_input_homepage")

DuckDuckGoMainSearchBar$sendKeysToElement(list("Nice."))

DuckDuckGoMainSearchBar$sendKeysToElement(list(key = "enter"))

####Other areas of maintanence including terminating the use of ports are not included in this script####
