require 'rails_helper'

RSpec.describe "Hotels", type: :request do
  #let! для создания данных перед каждым тестом в этом describe блоке
  let!(:city1) { create(:city, name: "Город А") }
  let!(:city2) { create(:city, name: "Город Б") }

  let!(:hotel1) { create(:hotel, name: "Альфа ", city: city1, rating: 4.5) }
  let!(:hotel2) { create(:hotel, name: "Бета ", city: city1, rating: 3.0) }
  let!(:hotel3) { create(:hotel, name: "Гамма ", city: city2, rating: 5.0) }
  let!(:hotel4) { create(:hotel, name: "Дельта ", city: city2, rating: 4.0) }

  #комнаты с разными характеристиками
  let!(:room1_h1) { create(:room, hotel: hotel1, room_type: 'Стандарт', capacity: 2, price: 2000) }
  let!(:room2_h1) { create(:room, hotel: hotel1, room_type: 'Люкс', capacity: 4, price: 5000) }
  let!(:room1_h2) { create(:room, hotel: hotel2, room_type: 'Стандарт', capacity: 2, price: 1500) }
  let!(:room1_h3) { create(:room, hotel: hotel3, room_type: 'Премиум', capacity: 5, price: 4000) }
  let!(:room2_h3) { create(:room, hotel: hotel3, room_type: 'Стандарт', capacity: 2, price: 2500) } #вторая комнату в hotel3 для теста distinct
  let!(:room3_h3) { create(:room, hotel: hotel3, room_type: 'Стандарт', capacity: 3, price: 2700) }
  let!(:room1_h4) { create(:room, hotel: hotel4, room_type: 'Стандарт', capacity: 2, price: 1800) }


  #пользователи и отзывы
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:review1_h1) { create(:review, hotel: hotel1, user: user1, rating: 5, created_at: 2.days.ago) }
  let!(:review2_h1) { create(:review, hotel: hotel1, user: user2, rating: 4, created_at: 1.day.ago) }

  let!(:hotel_with_images) { create(:hotel, :with_images, city: city1, created_at: 5.days.ago) }

  describe "GET #index" do
    #Тест базового отображения без параметров поиска
    context "when no search parameters" do
      before { get hotels_path }

      it "assigns @q" do
        expect(assigns(:q)).to be_a(Ransack::Search)
      end

      it "assigns @pagy and @hotels" do
        expect(assigns(:pagy)).to be_a(Pagy)
        expect(assigns(:hotels)).to match_array([hotel_with_images, hotel4, hotel3, hotel2, hotel1]) #Проверяем сортировку по created_at desc
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end

      it "includes pagination links with default items (12)" do
        expect(assigns(:pagy).count).to eq(5)
        expect(assigns(:pagy).vars[:items]).to eq(12) #Проверяем, что используется 12 элементов на страницу
        expect(assigns(:hotels).size).to eq(5)
      end

      it "assigns hotels with attached images included" do
         get hotels_path
         hotels_with_images = assigns(:hotels).select { |h| h.id == hotel_with_images.id }
         expect(hotels_with_images.first.images).to be_attached
      end

    end

    #Тесты с параметрами поиска (Ransack)
    context "when filtering with search parameters" do
      it "filters by hotel name" do
        get hotels_path, params: { q: { name_cont: "Альфа" } }
        expect(assigns(:hotels)).to match_array([hotel1])
        expect(assigns(:pagy).count).to eq(1)
      end

      it "filters by city" do
        get hotels_path, params: { q: { city_id_eq: city1.id } }
        expect(assigns(:hotels)).to match_array([hotel2, hotel1, hotel_with_images]) #По created_at desc
        expect(assigns(:pagy).count).to eq(3)
      end

      it "filters by room type" do
        #hotel1 и hotel3 имеют Стандартные номера
        get hotels_path, params: { q: { rooms_room_type_eq: "Стандарт" } }
        #Проверяем, что отели не дублируются из-за наличия нескольких стандартных номеров
        expect(assigns(:hotels)).to match_array([hotel4, hotel3, hotel2, hotel1]) #Все отели имеют Стандарт, кроме hotel3, у которого еще есть Приемиум
        expect(assigns(:pagy).count).to eq(4)
      end

      it "filters by minimum price" do
        #Отели с номерами >= 4000: hotel1 (5000), hotel3 (4000)
        get hotels_path, params: { q: { rooms_price_gteq: 4000 } }
        expect(assigns(:hotels)).to match_array([hotel3, hotel1])
        expect(assigns(:pagy).count).to eq(2)
      end

      it "filters by maximum price" do
        #Отели с номерами <= 2000: hotel1 (2000), hotel2 (1500), hotel4 (1800), hotel3 (2500) - нет, hotel3 не <=2000
        #Отели с номерами <= 2000: hotel1 (2000), hotel2 (1500), hotel4 (1800)
        get hotels_path, params: { q: { rooms_price_lteq: 2000 } }
        expect(assigns(:hotels)).to match_array([hotel4, hotel2, hotel1])
        expect(assigns(:pagy).count).to eq(3)
      end

      it "filters by price range" do
         #Отели с номерами между 2000 и 4000 (включительно): hotel1 (2000), hotel3 (2500), hotel3 (4000)
         #hotel1 есть, hotel3 есть (т.к. у него есть комнаты в этом диапазоне)
        get hotels_path, params: { q: { rooms_price_gteq: 2000, rooms_price_lteq: 4000 } }
        expect(assigns(:hotels)).to match_array([hotel3, hotel1])
        expect(assigns(:pagy).count).to eq(2)
      end

      it "filters by minimum capacity" do
        #Отели с вместимостью номеров >= 4: hotel1 (capacity 4), hotel3 (capacity 5)
        get hotels_path, params: { q: { rooms_capacity_gteq: 4 } }
        expect(assigns(:hotels)).to match_array([hotel3, hotel1])
        expect(assigns(:pagy).count).to eq(2)
      end

      it "filters by minimum rating" do
        #Отели с рейтингом >= 4.0: hotel1 (4.5), hotel3 (5.0), hotel4 (4.0)
        get hotels_path, params: { q: { rating_gteq: 4.0 } }
        expect(assigns(:hotels)).to match_array([hotel4, hotel3, hotel1])
        expect(assigns(:pagy).count).to eq(3)
      end

      it "handles distinct when multiple rooms match criteria" do
        #hotel3 имеет две комнаты (Стандарт 2500, Премиум 4000)
        #Фильтр по цене <= 3000 найдет Стандартный номер hotel3.
        get hotels_path, params: { q: { rooms_price_lteq: 3000 } }
        #Ожидаем отели с комнатами <= 3000: hotel1 (2000), hotel2 (1500), hotel3 (2500), hotel4 (1800)
        #Все 4 отеля имеют хотя бы одну комнату <= 3000
        expect(assigns(:hotels)).to match_array([hotel4, hotel3, hotel2, hotel1])
        expect(assigns(:pagy).count).to eq(4) #hotel3 не дублируется
      end


      it "filters by city and minimum rating" do
        get hotels_path, params: { q: { city_id_eq: city1.id, rating_gteq: 4.0 } }
        expect(assigns(:hotels)).to match_array([hotel1]) #hotel1 (Город А, Рейтинг 4.5), hotel2 (Город А, Рейтинг 3.0)
        expect(assigns(:pagy).count).to eq(1)
      end
    end

    context "when no hotels match the search" do
       it "assigns empty @hotels" do
         get hotels_path, params: { q: { name_cont: "Несуществующий отель" } }
         expect(assigns(:hotels)).to be_empty
         expect(assigns(:pagy).count).to eq(0)
       end
    end

    #Тест пагинации
    context "when requesting a specific page" do
       #Создадим больше отелей, чтобы было несколько страниц
       let!(:extra_hotels) { create_list(:hotel, 20, city: city1) } # 5 + 20 = 25 отелей
       before { get hotels_path, params: { page: 2 } }

      #  it "assigns the correct page of hotels" do
      #    all_hotels_sorted = Hotel.order(created_at: :desc).to_a
      #    expected_hotels_on_page2 = all_hotels_sorted[12..23] # Элементы с индексом 12 до 23 (12 штук)

      #    expect(assigns(:hotels)).to match_array(expected_hotels_on_page2)
      #    expect(assigns(:hotels).size).to eq(12)
      #    expect(assigns(:pagy).page).to eq(2)
      #    expect(assigns(:pagy).count).to eq(25)
      #  end
    end
  end

  describe "GET #show" do
    let!(:hotel_with_details) { create(:hotel, :with_rooms, :with_reviews, city: city1) } #Отель с комнатами и отзывами
    let!(:hotel_with_images) { create(:hotel, :with_images, city: city1) }

    #Тест базового отображения отеля без параметров дат
    context "when no check-in/check-out dates are provided" do
      before { get hotel_path(hotel_with_details) }

      it "assigns @hotel" do
        expect(assigns(:hotel)).to eq(hotel_with_details)
      end

      it "assigns a new @review" do
        expect(assigns(:review)).to be_a_new(Review)
      end

      it "assigns all @rooms for the hotel" do
        get hotel_path(hotel_with_details)
        expect(assigns(:rooms)).to match_array(hotel_with_details.rooms)
        expect(assigns(:rooms).count).to eq(hotel_with_details.rooms.count)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end

      it "assigns @booked_dates for all rooms in the hotel" do
         #несколько броней для разных комнат
         room_a = create(:room, hotel: hotel_with_details)
         room_b = create(:room, hotel: hotel_with_details)

         reservation_a1 = create(:reservation, room: room_a, check_in: Date.today + 5.days, check_out: Date.today + 7.days, user: user1)
         reservation_a2 = create(:reservation, room: room_a, check_in: Date.today + 10.days, check_out: Date.today + 12.days, user: user1)
         reservation_b1 = create(:reservation, room: room_b, check_in: Date.today + 6.days, check_out: Date.today + 8.days, user: user1)
        
         hotel_with_details.reload
         expected_booked_dates = hotel_with_details.rooms.reload.flat_map(&:booked_dates).map do |date_range|
             { from: date_range[:from].to_s, to: date_range[:to].to_s }
         end.uniq

         get hotel_path(hotel_with_details)

         expect(assigns(:booked_dates)).not_to be_nil
         expect(assigns(:booked_dates)).to be_an(Array)

         assigned_booked_dates_as_strings = assigns(:booked_dates).map do |date_range|
             { from: date_range[:from].to_s, to: date_range[:to].to_s }
         end
         expect(assigned_booked_dates_as_strings).to match_array(expected_booked_dates)
      end


      it "renders the show template" do
        get hotel_path(hotel_with_details)
        expect(response).to render_template(:show)
      end

      it "assigns a hotel with attached images when the trait is used" do
         get hotel_path(hotel_with_images)
         expect(assigns(:hotel).images).to be_attached #Проверяем, что изображения прикреплены
         expect(assigns(:hotel).images.count).to be >= 1 #Проверяем количество, если знаете его
      end
    end

    #Тесты с параметрами дат
    context "when valid check-in/check-out dates are provided" do
      let(:check_in_date) { Date.today + 2.weeks }
      let(:check_out_date) { check_in_date + 5.days }

      #Создаем отель и комнаты специально для этого контекста
      let!(:hotel_for_date_test) { create(:hotel, city: city1) }
      let!(:available_room) { create(:room, hotel: hotel_for_date_test) }
      let!(:partially_booked_room) { create(:room, hotel: hotel_for_date_test) }
      let!(:fully_booked_room) { create(:room, hotel: hotel_for_date_test) }
      let!(:other_room_available) { create(:room, hotel: hotel_for_date_test) } #Другая комната, не участвующая в бронированиях

      #Создаем бронирования, которые будут влиять на доступность
      #Бронь, делающая partially_booked_room недоступной в части запрошенного периода
      let!(:reservation_partial) { create(:reservation, room: partially_booked_room, check_in: check_in_date + 1.day, check_out: check_out_date + 1.day, user: user1) }
      # Бронь, делающая fully_booked_room полностью недоступной
      let!(:reservation_full) { create(:reservation, room: fully_booked_room, check_in: check_in_date - 1.day, check_out: check_out_date + 1.day, user: user2) }
      # Бронь, которая не должна влиять на доступность в этот период (например, закончилась до check_in)
      let!(:reservation_past) { create(:reservation, room: available_room, check_in: check_in_date - 5.days, check_out: check_in_date - 1.day, user: user1) }


      it "assigns @check_in and @check_out as Date objects" do
        get hotel_path(hotel_for_date_test), params: { check_in: check_in_date.to_s, check_out: check_out_date.to_s }
        expect(assigns(:check_in)).to eq(check_in_date)
        expect(assigns(:check_out)).to eq(check_out_date)
        expect(assigns(:check_in)).to be_a(Date)
        expect(assigns(:check_out)).to be_a(Date)
      end

      it "assigns @rooms with only available rooms using the scope" do
        get hotel_path(hotel_for_date_test), params: { check_in: check_in_date.to_s, check_out: check_out_date.to_s }

        #Ожидаем, что будут доступны available_room и other_room
        #partially_booked_room и fully_booked_room должны быть недоступны
        expected_available_rooms = [available_room, other_room_available]

        expect(assigns(:rooms)).to match_array(expected_available_rooms)
        expect(assigns(:rooms)).not_to include(partially_booked_room)
        expect(assigns(:rooms)).not_to include(fully_booked_room)
      end

      it "assigns @booked_dates for all rooms in the hotel even with date params" do
         #Этот тест похож на предыдущий, но убеждаемся, что @booked_dates все равно назначается
         #Создаем бронирования так же, как в предыдущем тесте для @booked_dates
         hotel_for_date_test.reload

         expected_booked_dates = hotel_for_date_test.rooms.flat_map(&:booked_dates).map do |date_range|
             { from: date_range[:from].to_s, to: date_range[:to].to_s }
         end.uniq

         get hotel_path(hotel_for_date_test), params: { check_in: check_in_date.to_s, check_out: check_out_date.to_s }

         expect(assigns(:booked_dates)).not_to be_nil
         assigned_booked_dates_as_strings = assigns(:booked_dates).map do |date_range|
             { from: date_range[:from].to_s, to: date_range[:to].to_s }
         end
         expect(assigned_booked_dates_as_strings).to match_array(expected_booked_dates)
      end

    end

    context "when invalid check-in/check-out dates are provided" do
      before { get hotel_path(hotel_with_details), params: { check_in: "not-a-date", check_out: "another-bad-date" } }

      it "assigns all @rooms for the hotel (falls back)" do
        expect(assigns(:rooms)).to match_array(hotel_with_details.rooms)
        expect(assigns(:rooms).count).to eq(hotel_with_details.rooms.count)
      end

      it "sets a flash alert message" do
        expect(flash.now[:alert]).to eq("Некорректный формат даты")
      end

      it "does not assign @check_in or @check_out as Date objects (they remain nil or original invalid strings)" do
         expect(assigns(:check_in)).not_to be_a(Date)
         expect(assigns(:check_out)).not_to be_a(Date)
      end

       it "assigns @booked_dates for all rooms in the hotel even with invalid date params" do
         #Создаем бронирования так же, как в тесте без дат
         room_a = create(:room, hotel: hotel_with_details)
         room_b = create(:room, hotel: hotel_with_details)
         reservation_a1 = create(:reservation, room: room_a, check_in: Date.today + 5.days, check_out: Date.today + 7.days, user: user1)
         reservation_a2 = create(:reservation, room: room_a, check_in: Date.today + 10.days, check_out: Date.today + 12.days, user: user1)
         reservation_b1 = create(:reservation, room: room_b, check_in: Date.today + 6.days, check_out: Date.today + 8.days, user: user1)


         expected_booked_dates = hotel_with_details.rooms.reload.flat_map(&:booked_dates).map do |date_range|
             { from: date_range[:from].to_s, to: date_range[:to].to_s }
         end.uniq

         get hotel_path(hotel_with_details), params: { check_in: "bad-date", check_out: "worse-date" }

         expect(assigns(:booked_dates)).not_to be_nil
         assigned_booked_dates_as_strings = assigns(:booked_dates).map do |date_range|
             { from: date_range[:from].to_s, to: date_range[:to].to_s }
         end
         expect(assigned_booked_dates_as_strings).to match_array(expected_booked_dates)
      end

    end

    # context "when the hotel does not exist" do
    #   it "raises a RecordNotFound error" do
    #     expect {
    #       get hotel_path(id: 99999) #ID, которого точно нет
    #     }.to raise_error(ActiveRecord::RecordNotFound)
    #     #expect(response).to have_http_status(:not_found)
    #   end
    # end
  end
end