# Pin npm packages by running ./bin/importmap

pin "application"
pin "@stripe/stripe-js", to: "https://cdn.jsdelivr.net/npm/@stripe/stripe-js/+esm"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "flatpickr", to: "flatpickr.js"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"