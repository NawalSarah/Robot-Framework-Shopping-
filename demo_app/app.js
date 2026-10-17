// A tiny fake web shop. It exists only so the Robot Framework tests have something to test.
// No server is needed: everything is stored in the browser (localStorage).

const USERS = {
  standard_user: { password: "Melollowowekfdsf123!", locked: false },
  locked_out_user: { password: "Melollowowekfdsf123!", locked: true },
};

const PRODUCTS = [
  { id: "backpack", name: "Backpack", price: 29.99 },
  { id: "bike-light", name: "Bike Light", price: 9.99 },
  { id: "t-shirt", name: "T-Shirt", price: 15.99 },
];

const getCart = () => JSON.parse(localStorage.getItem("cart") || "[]");
const saveCart = (cart) => localStorage.setItem("cart", JSON.stringify(cart));
const money = (n) => "$" + n.toFixed(2);

function requireLogin() {
  if (!localStorage.getItem("user")) window.location = "index.html";
}

function initLoginPage() {
  document.getElementById("login-button").addEventListener("click", () => {
    const username = document.getElementById("username").value.trim();
    const password = document.getElementById("password").value;
    const error = document.getElementById("error");
    let message = "";

    if (!username) message = "Username is required";
    else if (!password) message = "Password is required";
    else if (!USERS[username] || USERS[username].password !== password)
      message = "Username and password do not match";
    else if (USERS[username].locked) message = "This user has been locked out";

    if (message) {
      error.textContent = message;
      error.hidden = false;
      return;
    }
    localStorage.setItem("user", username);
    saveCart([]);
    window.location = "inventory.html";
  });
}

function updateBadge() {
  const badge = document.getElementById("cart-badge");
  const count = getCart().length;
  badge.textContent = count;
  badge.hidden = count === 0;
}

function initInventoryPage() {
  requireLogin();
  const list = document.getElementById("product-list");
  PRODUCTS.forEach((p) => {
    const row = document.createElement("div");
    row.className = "product";
    row.innerHTML = `<span>${p.name} - ${money(p.price)}</span>
      <button id="add-${p.id}">Add to cart</button>`;
    row.querySelector("button").addEventListener("click", () => {
      const cart = getCart();
      if (!cart.includes(p.id)) cart.push(p.id);
      saveCart(cart);
      updateBadge();
    });
    list.appendChild(row);
  });
  document.getElementById("logout-button").addEventListener("click", () => {
    localStorage.removeItem("user");
    window.location = "index.html";
  });
  updateBadge();
}

function initCartPage() {
  requireLogin();
  const render = () => {
    const cart = getCart();
    const ul = document.getElementById("cart-items");
    ul.innerHTML = "";
    let total = 0;
    cart.forEach((id) => {
      const p = PRODUCTS.find((x) => x.id === id);
      total += p.price;
      const li = document.createElement("li");
      li.className = "cart-item";
      li.innerHTML = `<span>${p.name} - ${money(p.price)}</span>
        <button id="remove-${p.id}">Remove</button>`;
      li.querySelector("button").addEventListener("click", () => {
        saveCart(getCart().filter((x) => x !== id));
        render();
      });
      ul.appendChild(li);
    });
    document.getElementById("cart-total").textContent = money(total);
    document.getElementById("empty-message").hidden = cart.length > 0;
  };
  render();
}
