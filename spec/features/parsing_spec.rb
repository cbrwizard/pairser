require 'spec_helper'
require 'rspec/expectations'

describe "parsing", :type => :feature do

  it "should increase parse request count on websites without instructions" do

    visit '/login'
    within("#new_user") do
      fill_in 'user_email', :with => 'admin@lol.ru'
      fill_in 'user_password', :with => 'qwerty'
    end
    click_button 'Войти'

    requests_before = ParseRequest.errors_count

    within("#parse-form") do
      fill_in :url, with: 'https://github.com/jnicklas/capybara'
    end
    click_button 'Вперёд!'

    requests_after = ParseRequest.errors_count
    requests_before.should_not == requests_after
  end


  it "should parse net-a-porter" do

    visit '/login'
    within("#new_user") do
      fill_in 'user_email', :with => 'admin@lol.ru'
      fill_in 'user_password', :with => 'qwerty'
    end
    click_button 'Войти'

    goods_before = User.find(1).goods.count

    within("#parse-form") do
      fill_in :url, with: 'http://www.net-a-porter.com/product/430685?cm_sp=homepage-_-live-_-430685'
    end
    click_button 'Вперёд!'

    goods_after = User.find(1).goods.count
    goods_before.should_not == goods_after
  end


  it "should parse pandora.net" do

    visit '/login'
    within("#new_user") do
      fill_in 'user_email', :with => 'admin@lol.ru'
      fill_in 'user_password', :with => 'qwerty'
    end
    click_button 'Войти'

    goods_before = User.find(1).goods.count

    within("#parse-form") do
      fill_in :url, with: 'http://www.pandora.net/en-us/gifts/suggestion#!790448/state/released'
    end
    click_button 'Вперёд!'

    goods_after = User.find(1).goods.count
    goods_before.should_not == goods_after
  end


  it "should parse pinterest.com" do

    visit '/login'
    within("#new_user") do
      fill_in 'user_email', :with => 'admin@lol.ru'
      fill_in 'user_password', :with => 'qwerty'
    end
    click_button 'Войти'

    goods_before = User.find(1).goods.count

    within("#parse-form") do
      fill_in :url, with: 'http://www.pinterest.com/pin/219761656791093675/'
    end
    click_button 'Вперёд!'

    goods_after = User.find(1).goods.count
    goods_before.should_not == goods_after
  end
end
