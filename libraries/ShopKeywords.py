"""Custom keyword library for the Demo Shop tests.

Why this file exists
--------------------
Robot Framework test files read like plain English ("Given I am logged in...").
Whenever a step needs real programming (start a browser with special options,
do arithmetic on prices), we write it here in Python and expose it as a keyword.

Every method decorated with @keyword becomes a keyword usable in .robot files.
"""
import os
from decimal import Decimal

from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn
from selenium import webdriver
from selenium.webdriver.chrome.service import Service

# Prices of the demo products, kept here so tests can calculate the expected total.
PRICES = {
    "backpack": Decimal("29.99"),
    "bike-light": Decimal("9.99"),
    "t-shirt": Decimal("15.99"),
}


@library(scope="SUITE", auto_keywords=False)
class ShopKeywords:
    @property
    def _selenium(self):
        """The SeleniumLibrary instance that Robot Framework already loaded."""
        return BuiltIn().get_library_instance("SeleniumLibrary")

    # ------------------------------------------------------------------ browser
    @keyword("Open Shop Browser")
    def open_shop_browser(self, url, headless=True):
        """Start Chrome (headless by default) and open ``url``.

        Optional environment variables (used in Docker / CI):
          CHROME_BINARY      path to the Chrome/Chromium executable
          CHROMEDRIVER_PATH  path to a matching chromedriver
        If they are not set, Selenium finds/downloads everything automatically.
        """
        options = webdriver.ChromeOptions()
        if str(headless).lower() in ("true", "1", "yes"):
            options.add_argument("--headless=new")
        options.add_argument("--window-size=1280,900")
        options.add_argument("--disable-dev-shm-usage")
        # Containers usually run as root, and Chrome refuses to start as root without this.
        if hasattr(os, "geteuid") and os.geteuid() == 0:
            options.add_argument("--no-sandbox")
        if os.environ.get("CHROME_BINARY"):
            options.binary_location = os.environ["CHROME_BINARY"]

        service = Service(os.environ["CHROMEDRIVER_PATH"]) if os.environ.get("CHROMEDRIVER_PATH") else Service()
        driver = webdriver.Chrome(service=service, options=options)
        self._selenium.register_driver(driver, alias="shop")
        self._selenium.go_to(url)

    # ------------------------------------------------------------------ calculations
    @keyword("Expected Total For")
    def expected_total_for(self, *product_ids):
        """Add up prices for the given product ids and return text like ``$39.98``."""
        total = sum((PRICES[p] for p in product_ids), Decimal("0.00"))
        return f"${total:.2f}"

    @keyword("Cart Should Contain Exactly")
    def cart_should_contain_exactly(self, *product_ids):
        """Fail unless the cart page lists exactly these products (any order)."""
        elements = self._selenium.get_webelements("css:.cart-item")
        shown = sorted(el.text.split(" - ")[0].lower().replace(" ", "-") for el in elements)
        wanted = sorted(product_ids)
        if shown != wanted:
            raise AssertionError(f"Cart shows {shown} but expected {wanted}")
