# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/hatebu_entry_getter'

describe HatebuEntryGetter do
      
  subject do
    HatebuEntryGetter.new
  end
  
  describe :get_entries_from_hotentry do
    it "返り値の配列の件数が0でなく、エラーがないこと" do
      res = subject.get_entries_from_hotentry
      subject.error?.should be_false
      #res
      res.each_with_index do |entry, i|
        puts i
        p entry
      end
      res.size.should > 24
    end
  end
  
  describe :get_entries_of_categories do
    it "返り値の配列の件数が0でなく、エラーがないこと" do
      res = subject.get_entries_of_categories
      subject.error?.should be_false
      res.each_with_index do |entry, i|
        #puts i
        #p entry
      end
      res.size.should >= 30
    end
  end

end
