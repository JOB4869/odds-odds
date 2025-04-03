import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["currentAddress", "paymentMethod", "promptpay", "form"]

  connect() {
    // ซ่อนทุก section เมื่อโหลดหน้า
    this.currentAddressTarget.style.display = "none"
    this.paymentMethodTarget.style.display = "none"
    this.promptpayTarget.style.display = "none"
  }

  toggleAddress(event) {
    const radio = event.target
    if (radio.value === "current_address") {
      this.currentAddressTarget.style.display = "block"
      this.paymentMethodTarget.style.display = "none"
      this.promptpayTarget.style.display = "none"
      // ตั้งค่า payment_method เป็น promptpay โดยอัตโนมัติ
      const promptpayRadio = this.formTarget.querySelector('input[name="buy_now[payment_method]"][value="promptpay"]')
      if (promptpayRadio) {
        promptpayRadio.checked = true
      }
    } else {
      this.currentAddressTarget.style.display = "none"
      this.paymentMethodTarget.style.display = "block"
    }
  }

  togglePayment(event) {
    const radio = event.target
    if (radio.value === "promptpay") {
      this.promptpayTarget.style.display = "block"
    } else {
      this.promptpayTarget.style.display = "none"
    }
  }

  validateForm(event) {
    event.preventDefault()
    
    const addressMethod = this.formTarget.querySelector('input[name="buy_now[address_method]"]:checked')
    if (!addressMethod) {
      alert("กรุณาเลือกที่รับสินค้า")
      return
    }

    if (addressMethod.value === "current_address") {
      const proofOfPayment = this.currentAddressTarget.querySelector('input[name="buy_now[proof_of_payment]"]')
      if (!proofOfPayment.files[0]) {
        alert("กรุณาอัปโหลดหลักฐานการชำระเงิน")
        return
      }
    } else {
      const paymentMethod = this.formTarget.querySelector('input[name="buy_now[payment_method]"]:checked')
      if (!paymentMethod) {
        alert("กรุณาเลือกวิธีการชำระเงิน")
        return
      }

      if (paymentMethod.value === "promptpay") {
        const proofOfPayment = this.promptpayTarget.querySelector('input[name="buy_now[proof_of_payment]"]')
        if (!proofOfPayment.files[0]) {
          alert("กรุณาอัปโหลดหลักฐานการชำระเงิน")
          return
        }
      }
    }

    this.formTarget.submit()
  }
} 