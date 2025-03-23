import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: Number
  }

  connect() {
    setTimeout(() => {
      this.element.style.opacity = '0'
      this.element.style.transition = 'opacity 0.5s ease-out'
      
      setTimeout(() => {
        this.element.remove()
      }, 500)
    }, this.timeoutValue)
  }
} 