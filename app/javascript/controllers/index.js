// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
// import GalleryController from "./gallery_controller.js"
// application.register("gallery", GalleryController)

// console.error("Manual registration of gallery controller attempted")