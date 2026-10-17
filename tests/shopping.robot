*** Settings ***
Documentation     BDD-style shopping scenarios. Read each test like a sentence.
Resource          ../resources/keywords.resource
Suite Setup       Start Shop Session
Suite Teardown    End Shop Session
Test Setup        Given I am logged in as a standard user

*** Test Cases ***
Adding one item shows 1 in the cart badge
    When I add "backpack" to the cart
    Then the cart badge should show    1

Adding two items updates the badge and the cart total
    When I add "backpack" to the cart
    And I add "bike-light" to the cart
    Then the cart badge should show    2
    When I open the cart
    Then Cart Should Contain Exactly    backpack    bike-light
    ${expected}=    Expected Total For    backpack    bike-light
    And the cart total should be    ${expected}

Removing an item updates the total
    When I add "backpack" to the cart
    And I add "t-shirt" to the cart
    And I open the cart
    And I remove "backpack" from the cart
    Then Cart Should Contain Exactly    t-shirt
    ${expected}=    Expected Total For    t-shirt
    And the cart total should be    ${expected}

Removing the last item shows an empty cart
    When I add "bike-light" to the cart
    And I open the cart
    And I remove "bike-light" from the cart
    Then the cart should be empty
    And the cart total should be    $0.00

Logging out sends the user back to the login page
    Click Button    id:logout-button
    Wait Until Location Contains    index.html
