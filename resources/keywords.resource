*** Settings ***
Documentation     Reusable BDD-style keywords (Given / When / Then).
...               Test files stay short and readable because the details live here.
Library           SeleniumLibrary
Library           ../libraries/ShopKeywords.py

*** Variables ***
${BASE_URL}       http://localhost:8000
${HEADLESS}       True
${GOOD_USER}      standard_user
${GOOD_PASSWORD}  Melollowowekfdsf123!

*** Keywords ***
# ---------- Setup / teardown ----------
Start Shop Session
    Open Shop Browser    ${BASE_URL}/index.html    headless=${HEADLESS}

End Shop Session
    Close All Browsers

# ---------- GIVEN ----------
I am on the login page
    Go To    ${BASE_URL}/index.html
    Execute Javascript    localStorage.clear()
    Reload Page
    Wait Until Element Is Visible    id:login-button

I am logged in as a standard user
    Given I am on the login page
    When I log in with    ${GOOD_USER}    ${GOOD_PASSWORD}
    Then I should see the products page

# ---------- WHEN ----------
I log in with
    [Arguments]    ${username}    ${password}
    Input Text      id:username    ${username}
    Input Text      id:password    ${password}
    Click Button    id:login-button

I add "${product}" to the cart
    Click Button    id:add-${product}

I open the cart
    Click Link    id:cart-link

I remove "${product}" from the cart
    Click Button    id:remove-${product}

# ---------- THEN ----------
I should see the products page
    Wait Until Location Contains    inventory.html
    Page Should Contain Element     id:product-list

I should see the error
    [Arguments]    ${expected_message}
    Wait Until Element Is Visible    id:error
    Element Text Should Be           id:error    ${expected_message}

the cart badge should show
    [Arguments]    ${expected_count}
    Element Text Should Be    id:cart-badge    ${expected_count}

the cart total should be
    [Arguments]    ${expected_total}
    Element Text Should Be    id:cart-total    ${expected_total}

the cart should be empty
    Element Should Be Visible    id:empty-message
