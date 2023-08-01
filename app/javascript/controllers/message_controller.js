import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message"
export default class extends Controller {
  static targets = ['deleteBtn', 'messageBox']
  connect() {
  }

  showDeleteBtn(){
    this.deleteBtnTarget.classList.toggle('hidden')
  }
}
