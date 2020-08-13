// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
import socket from "./socket"
//
import "phoenix_html"

let channel = socket.channel("translator", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on('translate', function(payload) {
    console.log(payload.eng_message)
    let message_input = document.getElementById('message-input')
    message_input.value = payload.eng_message
});


document.getElementById("submit-button").addEventListener('click', (e) => {
    e.preventDefault()
    console.log(e)
    let message_input = document.getElementById('message-input')
    channel.push('translate', { message: message_input.value })
    message_input.value = ""
});

