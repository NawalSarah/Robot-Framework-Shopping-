# Project 1 - Robot Framework UI Test Suite

## What is this, in plain English?
A robot that opens a web browser and uses a small demo shop the way a person would:
logs in, adds products to a cart, checks the total, logs out. After each step it checks the page
shows the right thing. If it does not, the test fails and the report tells you where.

The demo shop is included (`demo_app/`), so **no internet or accounts are needed**.

## Run it
```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python run_tests.py
```
You should see 11 tests, all `PASS`. Then open **`results/report.html`** (summary) and
**`results/log.html`** (every step, click through the failures).

Want to *watch* the browser? `python run_tests.py --variable HEADLESS:False`
Run only the login tests? `python run_tests.py --suite Login`

## How the pieces fit

```
run_tests.py                 starts the demo shop, runs the tests, stops the shop
demo_app/                    the fake shop (HTML + a little JavaScript) that gets tested
tests/
  login.robot                DATA-DRIVEN tests: one template, 6 rows of data
  shopping.robot             BDD tests: Given / When / Then scenarios
resources/keywords.resource  reusable steps in plain English ("I add "backpack" to the cart")
libraries/ShopKeywords.py    custom keywords written in Python (browser start-up, price maths)
Dockerfile                   packs the suite + Chrome into one container
.github/workflows/           GitHub Actions: runs the tests on every push and saves the report
```

Think of it in three layers: **tests** (what to check) -> **keywords** (how to do each step) -> **Python library** (the hard bits).

## Key ideas to understand

- **Data-driven testing** - `login.robot` has *one* test written once (`Login Should Show`) and a table of inputs.
  Adding a login case = adding a row. Open the file and look at the table.
- **BDD (Given / When / Then)** - tests read like sentences. `Given` = starting situation, `When` = the action,
  `Then` = what must be true afterwards. `And` repeats the previous word.
- **Custom keyword library** - `ShopKeywords.py` is plain Python. Any method with `@keyword` becomes a
  keyword. It starts Chrome with the right options and calculates the expected cart total.
- **Locators** - the tests find elements by `id:` (e.g. `id:login-button`). IDs are the most stable locator.
- **Waits instead of sleeps** - `Wait Until Element Is Visible` waits only as long as needed. `Sleep 5s` makes tests slow and flaky.
- **Headless** - Chrome runs without a window. Needed on servers/CI.

## Try these changes yourself (do at least two - this is how you learn it)

1. **Add a login case.** In `tests/login.robot`, copy a row and test the username `   ` (spaces) or a very long password. Run `python run_tests.py --suite Login`.
2. **Break the app and watch the test catch it.** In `demo_app/app.js` change `price: 29.99` to `30.99`. Run the tests. Which test fails and why? Change it back.
3. **Add a new scenario.** In `tests/shopping.robot`, write "Adding the same item twice keeps the badge at 1" (the app ignores duplicates).
4. **Add a new keyword** in `ShopKeywords.py` (for example `Cart Item Count Should Be`) and use it in a test.

## Docker and GitHub Actions (not run by the person who built this - try them once)
```bash
docker build -t robot-ui-suite .
docker run --rm -v "$(pwd)/results:/app/results" robot-ui-suite
```
For GitHub Actions: put this folder in its own GitHub repository and push. Open the **Actions** tab, then the run,
then download the **robot-report** artifact at the bottom.

## Talking points
- "The suite has 11 tests: 6 data-driven login cases and 5 BDD shopping scenarios."
- "I put the reusable steps in a resource file and the technical parts in a Python library so test files stay readable."
- "It runs in Docker and in GitHub Actions on every push; the HTML report is saved as an artifact even when tests fail."
