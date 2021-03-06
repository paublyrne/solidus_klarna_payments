require 'features_helper'

describe 'Altering order of payment options in checkout', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include_context "change driver"
  include WorkflowDriver::Process

  it 'Changes the order of payment options - Puts Klarna first', framework: :solidus do
      gateway = Spree::PaymentMethod.where("name LIKE :prefix", prefix: "#{Klarna}%").first
      gateway.position = 1
      gateway.save
      expect(gateway.position).to eq(1)

    klarna_order = order_on_state(product_name: 'Ruby on Rails Bag', state: :delivery, quantity: 1)

    on_the_payment_page do |page|
      page.load
      page.update_hosts
    end

    on_the_payment_page do |page|
      expect(page.displayed?).to be(true)
      expect(page.payment_methods.first).to have_content('Klarna')
    end

    Capybara.current_session.driver.quit
  end
end
