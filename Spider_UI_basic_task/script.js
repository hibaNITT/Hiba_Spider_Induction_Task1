// Function to simulate playing a demo track when the CTA button is clicked
function playDemo() {
  // This just shows an alert – in a real app you'd play audio
  alert("Playing demo track – enjoy the vibes!");
  console.log("Demo play button clicked");
}

// Function to handle newsletter subscription form submission
function subscribeNewsletter() {
  // Validate email (very basic check)
  var emailInput = document.querySelector(".newsletter-input");
  if (!emailInput) {
    alert("Newsletter input not found!");
    return false;
  }
  var email = emailInput.value.trim();
  if (email === "" || email.indexOf("@") === -1) {
    alert("Please enter a valid email address.");
    return false; // prevent form submission
  }
  // Show a friendly thank‑you message
  alert("Wow! Thank you for signing up to our cool list!");
  console.log("Newsletter subscribed:", email);
  // Reset the form (optional)
  emailInput.value = "";
  return false; // keep the page from reloading
}

// OPTIONAL: Simple view‑mode toggler (desktop / mobile preview)
function setViewMode(mode) {
  // mode can be 'desktop' or 'mobile'
  var body = document.body;
  body.classList.remove("view-desktop", "view-mobile");
  if (mode === "desktop") {
    body.classList.add("view-desktop");
  } else if (mode === "mobile") {
    body.classList.add("view-mobile");
  }
  console.log("View mode set to", mode);
}
