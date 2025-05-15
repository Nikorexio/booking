import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate"]
  static values = { bookedDates: Array }
  
  connect() {
    console.log("initDatepicker controller connected")
    this.initDatepicker()
  }

  initDatepicker() {
    const disableDates = this.bookedDatesValue.map(d => ({
      from: d.from,
      to: d.to
    }))

    this.startPicker = flatpickr(this.startDateTarget, {
      minDate: "today",
      disable: disableDates,
      onChange: (selectedDates) => {
        if (selectedDates.length) {
          this.endDateTarget._flatpickr.set("minDate", selectedDates[0])
        }
      }
    })

    this.endPicker = flatpickr(this.endDateTarget, {
      minDate: (this.startDateTarget.value) || "tomorrow",
      disable: disableDates
    })
  }

  updateMinDate(event) {
    const selectedDate = new Date(event.target.value)
    this.endPicker.set("minDate", selectedDate)
    if (this.endPicker.selectedDates[0] < selectedDate) {
      this.endPicker.setDate(selectedDate)
    }
  }
}