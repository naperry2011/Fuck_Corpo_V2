// Same math as the app (app/lib/core/rate.dart): salary is spread over
// 52 weeks of the hours you enter; hourly is just divided by 3600.
const WEEKS_PER_YEAR = 52;
const WORKDAYS_PER_YEAR = 5 * WEEKS_PER_YEAR;
// Hypothetical CEO on a $20M package, paid around the clock (app/lib/copy/roasts.dart).
const CEO_PER_SECOND = 20000000 / (365 * 24 * 3600);

function perSecond(type, amount, hoursPerWeek) {
  if (!(amount > 0)) return 0;
  if (type === "hourly") return amount / 3600;
  if (!(hoursPerWeek > 0)) return 0;
  return amount / (hoursPerWeek * WEEKS_PER_YEAR * 3600);
}

function fmt(value, currency, decimals = 2) {
  const n = value.toLocaleString("en-US", {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
  return currency + n;
}

// Live "earned while you read this" ticker at a $25/hr default.
(function ticker() {
  const el = document.getElementById("ticker");
  if (!el) return;
  const rate = perSecond("hourly", 25, 40);
  const start = performance.now();
  const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const tick = () => {
    el.textContent = fmt(rate * ((performance.now() - start) / 1000), "$", 4);
    if (!reduced) requestAnimationFrame(tick);
  };
  if (reduced) setInterval(tick, 1000);
  tick();
})();

(function calculator() {
  const form = document.getElementById("calc");
  if (!form) return;
  const $ = (id) => document.getElementById(id);
  const num = (id) => parseFloat($(id).value);

  function update() {
    const type = form.elements.paytype.value;
    const currency = form.elements.currency.value;
    const amount = num("amount");
    const hours = num("hours");
    const minutes = num("minutes");
    const perDay = num("perday");

    let error = "";
    if (!(amount > 0)) error = "Put a real wage in, champ.";
    else if (!(hours > 0) || hours > 168) error = "Hours per week: between 1 and 168.";
    else if (!(minutes > 0) || minutes > 480) error = "Minutes per dump: 1 to 480.";
    else if (!(perDay > 0) || perDay > 20) error = "Dumps per workday: 1 to 20. Please see a doctor past that.";
    $("calc-error").textContent = error;
    $("amount-suffix").textContent = type === "hourly" ? "/ hr" : "/ yr";
    if (error) return;

    const rate = perSecond(type, amount, hours);
    const perDump = rate * minutes * 60;
    const yearly = perDump * perDay * WORKDAYS_PER_YEAR;
    $("out-rate").textContent = fmt(rate, currency, 4) + " / sec";
    $("out-dump").textContent = fmt(perDump, currency);
    $("out-year").textContent = fmt(yearly, currency);
    $("out-hours").textContent = ((minutes * perDay * WORKDAYS_PER_YEAR) / 60).toFixed(0) + " hrs";
    $("out-ceo").textContent =
      "A CEO on a 20 million package makes your whole year of paid dumps in " +
      Math.max(1, Math.round(yearly / CEO_PER_SECOND / 60)) +
      " minutes. You still won.";
  }

  form.addEventListener("input", update);
  form.addEventListener("submit", (e) => e.preventDefault());
  update();
})();
