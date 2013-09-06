# -*- encoding: UTF-8 -*-

require 'test_helper'

class SiteCreateFromRankActionTest < ActiveSupport::TestCase
  
  def setup
    @action = SiteCreateFromRankAction.new
  end
  
  #
  #
  #
  test "exec 取得した配列のサイズが一定以上である" do
    @action.exec
    
    sites = Site.all
    sites.each do |site|
      p site
    end
    min_expected = 50
    assert min_expected <= sites.size
  end
end
