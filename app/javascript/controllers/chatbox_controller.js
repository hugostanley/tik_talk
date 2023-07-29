import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['chatBoxDiv', 'form']
  connect(){
    this.chatBoxDivTarget.scrollTo({
      top: this.chatBoxDivTarget.scrollHeight,
      left: 0,
    })

  }
  reset() {
    this.formTarget.reset()
  }

  scrollIntoView(){
    this.chatBoxDivTarget.scrollTo({
      top: this.chatBoxDivTarget.scrollHeight,
      left: 0,
      behavior: "smooth"
    })

  }
}
