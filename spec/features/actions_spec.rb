require 'spec_helper'
require 'rspec/expectations'

describe "user_actions", :type => :feature do

  it "triggers_evacuation", :js => true do
    visit '/'
    people_left_before = Stat.first.people_left

    find("#evac_btn").click
    find("#share_btn").should be_visible
    people_left_after = Stat.first.people_left

    people_left_after.should == people_left_before + 1
  end
end
