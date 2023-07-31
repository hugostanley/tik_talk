import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['dropdownDiv', 'dropdownIcon']

  toggle(){
    this.dropdownDivTarget.classList.toggle('hidden')
    window.addEventListener('click', this.close.bind(this), false)
  }

  close(e){
    if(e.target != this.dropdownIconTarget){
      this.dropdownDivTarget.classList.add('hidden')
    }
  }

  disconnect(){
    window.removeEventListener('click', this.close)
  }
}
