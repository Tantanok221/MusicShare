import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.handleOutsideClick = this.handleOutsideClick.bind(this)
        document.addEventListener("click", this.handleOutsideClick)
    }

    disconnect() {
        document.removeEventListener("click", this.handleOutsideClick)
    }

    handleOutsideClick(event) {
        if (!this.element.contains(event.target)) {
            // Replace the turbo frame with an empty one
            const frame = document.getElementById("user_modal")
            if (frame) frame.innerHTML = ""
        }
    }
}
