import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["normal", "hover", "active"]

  connect() {
    // Add styles dynamically
    const style = document.createElement('style')
    style.textContent = `
      .logo-container {
        position: relative;
        width: 140px;
        height: 80px;
        cursor: pointer;
        padding: 1rem;
        transition: all 0.3s ease;
      }

      .logo-container img {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        object-fit: contain;
        transition: opacity 0.3s ease;
      }

      .logo-normal {
        opacity: 1;
      }

      .logo-hover, .logo-active {
        opacity: 0;
      }

      .logo-container:hover .logo-normal {
        opacity: 0;
      }

      .logo-container:hover .logo-hover {
        opacity: 1;
      }

      .logo-container:active .logo-hover {
        opacity: 0;
      }

      .logo-container:active .logo-active {
        opacity: 1;
      }

      .header-container {
        margin-bottom: 0.5rem;
        background-color: white;
      }

      .bottom-container {
        position: fixed;
        bottom: 0;
        width: 100%;
        background: transparent;
        text-align: center;
      }
      .content {
        margin-bottom: 80px;
      }
    `
    document.head.appendChild(style)
  }
} 