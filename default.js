// filter characters on keyboard event (alphabets)
function acceptLetters(e) {
  var keyControls = [8, 9, 13, 27, 46, 91, 92, 93];
  var keyLetters = "abcdefghijklmnopqrstuvwxyz-";

  var key;  
  if (window.event) key = window.event.keyCode;
    else if (e) key = e.which;
      else return true;

  var keyChar = String.fromCharCode(key).toLowerCase();
  if (keyControls.indexOf(key) >= 0) return true;
    else if (keyLetters.indexOf(keyChar) >= 0) return true;
      else {
        e.preventDefault();
        return false;
      }
}

// filter characters on keyboard event (numerics)
function acceptNumbers(e) {
  var keyControls = [8, 9, 13, 27, 46, 91, 92, 93];
  var keyNumbers = "0123456789-";

  var key;
  if (window.event) key = window.event.keyCode;
    else if (e) key = e.which;
      else return true;

  var keyChar = String.fromCharCode(key).toLowerCase();
  if (keyControls.indexOf(key) > -1) return true;
    else if (keyNumbers.indexOf(keyChar) > -1) return true;
      else {
        e.preventDefault();
        return false;
      }
}

// document.addEventListener("DOMContentLoaded", function() {
//   document.getElementById("edLetters").addEventListener("keypress", acceptLetters);
//   document.getElementById("edNumbers").addEventListener("keypress", acceptNumbers);
// });

function setupDefault() {
  document.getElementById("edLetters").addEventListener("keypress", acceptLetters);
}

// setup app variables
function setupOlahKata() {
  var edLetters = document.getElementById("edLetters");
  if (edLetters) {
    edLetters.addEventListener("keypress", acceptLetters);
    edLetters.setAttribute("autoFocus", "");
    edLetters.setAttribute("maxlength", "13");
    edLetters.setAttribute("placeholder", "huruf acak...");
    // window.addEventListener("load", edLetters.focus());
  }
}

// setup app events
document.addEventListener("DOMContentLoaded", function() {
  if (appName == "default") setupDefault();
  if (appName == "olahkata") setupOlahKata();
});

window.addEventListener("load", function() {
  if (appName == "default") document.getElementById("edLetters").focus();
  if (appName == "olahkata") document.getElementById("edLetters").focus();
});
