import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["image", "thumbnail"]
    static values = { index: Number }
  
    connect() {
      console.log("Gallery controller connected");
      this.indexValue = 0
      this.showCurrentImage()
    }
  
    next(event) {
        console.log("Next button clicked");
      if (this.indexValue < this.imageTargets.length - 1) {
        this.indexValue++
        this.showCurrentImage()
      }
    }
  
    previous(event) {
        console.log("Previous button clicked");
      if (this.indexValue > 0) {
        this.indexValue--
        this.showCurrentImage()
      }
    }
  
    showCurrentImage() {
        console.log(`Showing image at index: ${this.indexValue}`);
      this.imageTargets.forEach((img, index) => {
        img.classList.toggle('hidden', index !== this.indexValue)
      })
      this.thumbnailTargets.forEach((thumb, index) => {
        thumb.classList.toggle('border-blue-500', index === this.indexValue)
      })
    }
  }