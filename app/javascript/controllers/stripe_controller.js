import { Controller } from "@hotwired/stimulus"
import { loadStripe } from '@stripe/stripe-js'

export default class extends Controller {
  static targets = ["card", "submit"]

  connect() {
    console.log("Stripe controller connected")
    
    const publishableKey = this.element.dataset.stripePublicKey;
    if (!publishableKey) {
      console.error("Stripe publishable key is not provided in data-stripe-public-key");
      return;
    }

    
    loadStripe(publishableKey).then(stripe => {
      this.stripe = stripe;
      this.elements = this.stripe.elements();
      this.initializeCardElement(); // Инициализируем элементы после получения объекта Stripe
    }).catch(error => {
      console.error("Failed to load Stripe:", error);
    });

    this.cardElement = null;
  }

  async initializeCardElement() {
    if (this.elements && this.cardTarget) {
        // Убеждаемся, что elements и target существуют
       this.cardElement = this.elements.create('card');
       this.cardElement.mount(this.cardTarget);
         } else {
       console.error("Stripe elements or card target not available.");
        }
    }

    async handlePayment(e) {
        e.preventDefault();
        this.submitTarget.disabled = true; // Отключаем кнопку сразу
    
        if (!this.stripe || !this.cardElement) {
          console.error("Stripe not initialized or card element not mounted.");
          this.submitTarget.disabled = false; // Включаем кнопку обратно при ошибке инициализации
          alert("Произошла ошибка при инициализации оплаты. Попробуйте позже.");
          return;
        }
    
        // Получаем client_secret из data-атрибута на элементе контроллера
        const clientSecret = this.element.dataset.stripeClientSecret;
         if (!clientSecret) {
          console.error("Stripe client secret is not provided in data-stripe-client-secret");
          this.submitTarget.disabled = false;
          alert("Произошла ошибка при обработке платежа. Не найден ключ.");
          return;
        }
    
    
        const { error, paymentIntent } = await this.stripe.confirmCardPayment(
          clientSecret, // Используем clientSecret, полученный из data-атрибута
          {
            payment_method: {
              card: this.cardElement,
              // Можно добавить billing_details если есть форма с адресом и именем
            }
          }
        );
    
        if (error) {
          console.error("Stripe payment failed:", error);
          alert(error.message);
          this.submitTarget.disabled = false; // Включаем кнопку обратно при ошибке Stripe
        } else if (paymentIntent && paymentIntent.status === 'succeeded') {
           console.log("Stripe payment succeeded:", paymentIntent);
           // Платеж успешен! Обычно здесь выполняется редирект или обновление страницы.
           // Turbo Drive может обрабатывать редирект автоматически после успешного POST запроса.
           // Если вы отправляете форму POST методом, Turbo Drive сделает редирект на show/success страницу.
           // Если вы просто обрабатываете submit без POST формы, возможно, нужен ручной редирект:
           // window.location.href = '/reservation/success'; // Пример
        } else {
            // Обработка других статусов paymentIntent, если нужно
             console.log("Stripe payment intent status:", paymentIntent.status);
             this.submitTarget.disabled = false;
        }
    }
}