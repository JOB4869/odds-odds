import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "password"]

  connect() {
    this.togglePassword = this.togglePassword.bind(this)
  }

  togglePassword(event) {
    const isChecked = event.target.checked
    this.passwordTargets.forEach(field => {
      field.type = isChecked ? "text" : "password"
    })
  }
} 