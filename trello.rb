require 'capybara/minitest'
require 'minitest/autorun'
require 'selenium-webdriver'


Capybara.default_driver = :selenium_chrome


Capybara.register_driver :selenium do |app|

  desired_capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'chromeOptions' => {
      'prefs' => {
        'intl.accept_languages' => 'en-US'
     }
   }
  )

  Capybara::Selenium::Driver.new(app, { browser: :chrome, desired_capabilities: desired_capabilities })
end

Capybara.javascript_driver = :chrome
Capybara.default_driver = :selenium


class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  FAKE_USER = 'unknown login'
  REAL_USER = 'rogalik1'
  PASSWORD_RUSER = 'bulkazmaslem'

  def test_unexisting_login
    visit 'https://trello.com/'
    find('.btn-sm', text: 'Log In').click
    assert_text 'Log in to Trello'
    fill_in 'user', with: FAKE_USER
    find('#login').click
    assert_text 'There isn\'t an account for this username'
  end

  def test_succesful_login
    visit 'https://trello.com/'
    find('.btn-sm', text: 'Log In').click
    assert_text 'Log in to Trello'
    fill_in 'user', with: REAL_USER
    fill_in 'password', with: PASSWORD_RUSER
    find('#login').click
    find('a[href=\'/rogalik1/boards\']', wait: 8) # waiting for the page to load to match the assertions
    assert_text 'Tablice prywatne'
  end

  def test_registering_account # without email confirmation
    timestamp = Time.now.strftime('%Y%m%d%H%M%S').to_s
    username = 'Kameleon' + timestamp

    # collect the randomly generated email
    visit 'https://temp-mail.org/'
    assert_text 'Your Temporary Email Address'
    new_email = find('#mail').value

    visit 'https://trello.com/signup'
    assert_text 'Create a Trello Account'
    fill_in 'email', with: new_email
    find('.signup-redirect').click
    find('#name', wait: 8) # waiting for the page to load to match the assertions
    fill_in 'name', with: username
    fill_in 'password', with: 'Password1'
    find('#signup').click
    find('.first-board-text', wait: 8)
    assert_text 'Welcome to Trello!'
    # TODO: email confirmation check
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

end
