require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe "Redcar::Menu::Builder DSL" do
  it "creates a menu" do
    builder = Redcar::Menu::Builder.new {}
    builder.menu.should be_an_instance_of(Redcar::Menu)
    builder.menu.length.should == 0
  end
  
  it "adds entries to the menu" do
    builder = Redcar::Menu::Builder.new do
      item "New", :NewCommand
    end
    builder.menu.length.should == 1
    item = builder.menu.entries.first
    item.text.should == "New"
    item.command.should == :NewCommand
  end
  
  it "adds separators to the menu" do
    builder = Redcar::Menu::Builder.new do
      separator
    end
    builder.menu.length.should == 1
    item = builder.menu.entries.first
    item.should be_an_instance_of(Redcar::Menu::Item::Separator)
  end
  
  it "adds submenus to the menu" do
    builder = Redcar::Menu::Builder.new do
      sub_menu "Export" do
        item "PDF", :PDFCommand
      end
      item "Exit", :ExitCommand
    end
    builder.menu.length.should == 2
    sub_menu = builder.menu.entries.first
    sub_menu.should be_an_instance_of(Redcar::Menu)
    sub_menu.text.should == "Export"
    sub_menu.length.should == 1
    sub_menu.entries.first.text.should == "PDF"
    top_item = builder.menu.entries.last
    top_item.text.should == "Exit"
  end
end