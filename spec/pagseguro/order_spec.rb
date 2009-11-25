require File.dirname(__FILE__) + "/../spec_helper"

describe PagSeguro::Order do
  before(:each) do
    @order = PagSeguro::Order.new
    @product = {:price => 9.90, :description => "Ruby 1.9 PDF", :id => 1}
  end

  it "should set order id when instantiating object" do
    @order = PagSeguro::Order.new("ABCDEF")
    @order.id.should == "ABCDEF"
  end

  it "should set order id throught setter" do
    @order.id = "ABCDEF"
    @order.id.should == "ABCDEF"
  end

  it "should reset products" do
    @order.products += [1,2,3]
    @order.products.should have(3).items
    @order.reset!
    @order.products.should be_empty
  end

  it "should alias add method" do
    @order.should_receive(:<<).with(:id => 1)
    @order.add :id => 1
  end

  it "should add product with default settings" do
    @order << @product
    @order.products.should have(1).item

    p = @order.products.first
    p[:price].should == 990
    p[:description].should == "Ruby 1.9 PDF"
    p[:id].should == 1
    p[:quantity].should == 1
    p[:weight].should be_nil
    p[:fees].should be_nil
    p[:shipping].should be_nil
  end

  it "should add product with custom settings" do
    @order << @product.merge(:quantity => 3, :shipping => 3.50, :weight => 100, :fees => 1.50)
    @order.products.should have(1).item

    p = @order.products.first
    p[:price].should == 990
    p[:description].should == "Ruby 1.9 PDF"
    p[:id].should == 1
    p[:quantity].should == 3
    p[:weight].should == 100
    p[:shipping].should == 350
    p[:fees].should == 150
  end

  it "should convert amounts to cents" do
    @order << @product.merge(:price => 9.99, :shipping => 3.67)

    p = @order.products.first
    p[:price].should == 999
    p[:shipping].should == 367
  end

  it "should convert big decimal to cents" do
    @product.merge!(:price => BigDecimal.new("199.00"))
    @order << @product

    p = @order.products.first
    p[:price].should == 19900
  end

  it "should convert weight to grammes" do
    @order << @product.merge(:weight => 1.3)
    @order.products.first[:weight].should == 1300
  end
end
