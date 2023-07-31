import { Controller } from "@hotwired/stimulus"
import mrujs from "mrujs"
mrujs.start()

// Connects to data-controller="authenticity"
export default class extends Controller {
   connect() {
    const form = this.element.parentNode
    if (form.querySelector("input[name='authenticity_token']") == null) {
      this.element.closest("form").appendChild(this.authenticityToken())
    }
  }

  authenticityToken() {
    const input = document.createElement("input")

    input.type = "hidden"
    input.name = "authenticity_token"
    input.autocomplete = "off"
    input.value = window.mrujs.csrfToken()

    return input
  }
}
