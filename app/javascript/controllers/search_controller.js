import { Controller } from "@hotwired/stimulus"
import debounce from 'debounce'

// Connects to data-controller="search"
export default class extends Controller {
  initialize(){
    this.submit = debounce(this.submit.bind(this), 300)
  }

  submit(){
    this.element.requestSubmit()
  }

  focus(){
    const svg = document.querySelector("#search_input .icon--ei-chevron-left")
    svg.classList.remove('deanimate-input')
    svg.classList.add('animate-input')
    svg.classList.remove('!hidden')
  }

  exit(){
    const svg = document.querySelector("#search_input .icon--ei-chevron-left")
    svg.classList.remove('animate-input')
    svg.classList.add('deanimate-input')
    this.element.reset()
  }

}
