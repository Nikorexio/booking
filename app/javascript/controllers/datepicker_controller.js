import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate"]
  static values = { bookedDates: Array }
  
  startPicker;
  endPicker;

  connect() {
    console.log("initDatepicker controller connected")
    this.initDatepicker()
  }

  initDatepicker() {
    const disableDates = this.bookedDatesValue.map(d => ({
      from: d.from,
      to: d.to
    }))
    const initialStartDateValue = this.startDateTarget.value;
    let initialMinEndDate;
    
    if (initialStartDateValue) {
        try {
          const initialStartDate = flatpickr.parseDate(initialStartDateValue, 'Y-m-d');
          const dayAfterInitialStartDate = initialStartDate.fp_incr(1);
          initialMinEndDate = flatpickr.formatDate(dayAfterInitialStartDate, 'Y-m-d');
        } catch (error) {
          console.error("Error parsing initial start date for endPicker:", error);
          initialMinEndDate = "tomorrow";
        }
      } else {
        initialMinEndDate = "tomorrow";
    }

    this.startPicker = flatpickr(this.startDateTarget, {
      minDate: "today",
      disable: disableDates,
      onChange: (selectedDates, dateStr, instance) => {
        if (selectedDates.length > 0) {
          const newMinEndDate = selectedDates[0].fp_incr(1);

          this.endPicker.set("minDate", newMinEndDate);

          if (this.endPicker.selectedDates.length > 0 && this.endPicker.selectedDates[0] < newMinEndDate) {
              this.endPicker.setDate(newMinEndDate);
          } else if (this.endPicker.selectedDates.length === 0) {
              this.endPicker.setDate(newMinEndDate);
          }

        } else {
           this.endPicker.set("minDate", "tomorrow");
        }
      }
    });

    this.endPicker = flatpickr(this.endDateTarget, {
      minDate: initialMinEndDate,
      disable: disableDates,
    });
  }
}