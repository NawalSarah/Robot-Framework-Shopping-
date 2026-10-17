*** Settings ***
Documentation     DATA-DRIVEN login tests.
...               One test template + a table of inputs = many test cases.
...               To add a case, just add a row to the table at the bottom.
Resource          ../resources/keywords.resource
Suite Setup       Start Shop Session
Suite Teardown    End Shop Session
Test Template     Login Should Show

*** Test Cases ***                          USERNAME            PASSWORD         EXPECTED MESSAGE
Valid user reaches products page            standard_user       ${GOOD_PASSWORD}  ${EMPTY}
Locked out user is rejected                 locked_out_user     ${GOOD_PASSWORD}  This user has been locked out
Wrong password is rejected                  standard_user       wrong_password   Username and password do not match
Unknown user is rejected                    nobody              ${GOOD_PASSWORD}  Username and password do not match
Empty username is rejected                  ${EMPTY}            ${GOOD_PASSWORD}  Username is required
Empty password is rejected                  standard_user       ${EMPTY}         Password is required

*** Keywords ***
Login Should Show
    [Documentation]    If EXPECTED is empty we expect success, otherwise we expect that error text.
    [Arguments]    ${username}    ${password}    ${expected_message}
    Given I am on the login page
    When I log in with    ${username}    ${password}
    IF    '${expected_message}' == ''
        Then I should see the products page
    ELSE
        Then I should see the error    ${expected_message}
    END
