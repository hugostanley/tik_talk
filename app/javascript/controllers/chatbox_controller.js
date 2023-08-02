import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['chatBoxDiv', 'form', 'textArea']
  connect() {
    this.chatBoxDivTarget.scrollTo({
      top: this.chatBoxDivTarget.scrollHeight,
      left: 0,
    })

  }
  reset() {
    this.formTarget.reset()
  }

  submitOnEnter(e) {
    e.preventDefault()
    if (this.textAreaTarget.value === "") return
    this.formTarget.requestSubmit()
  }

  scrollIntoView() {
    this.chatBoxDivTarget.scrollTo({
      top: this.chatBoxDivTarget.scrollHeight,
      left: 0,
      behavior: "smooth"
    })

  }
}
