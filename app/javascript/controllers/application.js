import { Application } from "@hotwired/stimulus"
// import ModalController from "./modal_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
// application.register("modal", ModalController)
window.Stimulus   = application

export { application }
