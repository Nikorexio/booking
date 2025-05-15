import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter"]
  
  connect() {
    this.useMutationObserver = true
    this.textarea = this.element.querySelector("textarea")

    if (!this.textarea) {
      console.log("Textarea не найден внутри textarea-counter контроллера")
      return
    }

    this.updateCounter()

    this.textarea.addEventListener("input", () => this.updateCounter())
  }

  updateCounter() {
    const maxLength = parseInt(this.textarea.getAttribute("maxlength"), 10)
    const currentLength = this.textarea.value.length || 0
    const remaining = maxLength - currentLength
    // console.log(`Осталось символов: ${remaining}`)
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = remaining
    }
  }
}