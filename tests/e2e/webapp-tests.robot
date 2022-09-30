*** Settings ***
Library  SeleniumLibrary

*** Test Cases ***
Hello button API call
    [Tags]  selenium  goodbye
    Open URL In Browser
    Click Button  hello-btn
    Element Should Contain  text  Hello, 

Goodbye button API call
    [Tags]  selenium  hello
    Open URL In Browser
    Click Button  goodbye-btn
    Element Should Contain  text  Goodbye, 
    [Teardown]  Close All Browsers

*** Keywords ***
Open URL In Browser
    Open Browser  ${URL}  ${BROWSER}
    Title Should Be  Python Webapp
    Element Text Should Be  text  Welcome!