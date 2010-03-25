require File.dirname(__FILE__) + "/../spec_helper"

describe PagSeguro::Notification do
  before(:each) do
    @the_params = {}
    @notification = PagSeguro::Notification.new(@the_params)
  end
  
  it "should return real url for non-developer mode" do
    PagSeguro.stub!(:developer?).and_return(false)
    @notification.api_url.should == PagSeguro::Notification::API_URL
  end
  
  it "should not request the confirmation url when running developer mode" do
    PagSeguro.stub!(:developer?).and_return(true)
    Net::HTTP.should_not_receive(:new)
    @notification.should be_valid
  end
  
  describe "status mapping" do
    it "should be completed" do
      set_status!("Completo")
      @notification.status.should == :completed
    end
    
    it "should be pending" do
      set_status!("Aguardando Pagto")
      @notification.status.should == :pending
    end
    
    it "should be approved" do
      set_status!("Aprovado")
      @notification.status.should == :approved
    end
    
    it "should be verifying" do
      set_status!("Em Análise")
      @notification.status.should == :verifying
    end
    
    it "should be canceled" do
      set_status!("Cancelado")
      @notification.status.should == :canceled
    end
    
    it "should be refunded" do
      set_status!("Devolvido")
      @notification.status.should == :refunded
    end
  end
  
  describe "payment mapping" do
    it "should be credit card" do
      set_payment!("Cartão de Crédito")
      @notification.payment_method.should == :credit_card
    end
    
    it "should be invoice" do
      set_payment!("Boleto")
      @notification.payment_method.should == :invoice
    end
    
    it "should be pagseguro" do
      set_payment!("Pagamento")
      @notification.payment_method.should == :pagseguro
    end
    
    it "should be online transfer" do
      set_payment!("Pagamento online")
      @notification.payment_method.should == :online_transfer
    end
  end
  
  describe "buyer mapping" do
    it "should return client name" do
      param!("CliNome", "John Doe")
      @notification.buyer[:name].should == "John Doe"
    end
    
    it "should return client email" do
      param!("CliEmail", "john@doe.com")
      @notification.buyer[:email].should == "john@doe.com"
    end
    
    it "should return client phone" do
      param!("CliTelefone", "11 55551234")
      @notification.buyer[:phone][:area_code].should == "11"
      @notification.buyer[:phone][:number].should == "55551234"
    end
    
    describe "address" do
      it "should return street" do
        param!("CliEndereco", "Av. Paulista")
        @notification.buyer[:address][:street].should == "Av. Paulista"
      end

      it "should return number" do
        param!("CliNumero", "2500")
        @notification.buyer[:address][:number].should == "2500"
      end
      
      it "should return complements" do
        param!("CliComplemento", "Apto 123-A")
        @notification.buyer[:address][:complements].should == "Apto 123-A"
      end
      
      it "should return neighbourhood" do
        param!("CliBairro", "Bela Vista")
        @notification.buyer[:address][:neighbourhood].should == "Bela Vista"
      end
      
      it "should return city" do
        param!("CliCidade", "São Paulo")
        @notification.buyer[:address][:city].should == "São Paulo"
      end
      
      it "should return state" do
        param!("CliEstado", "SP")
        @notification.buyer[:address][:state].should == "SP"
      end
      
      it "should return postal code" do
        param!("CliCEP", "01310300")
        @notification.buyer[:address][:postal_code].should == "01310300"
      end
    end
  end
  
  describe "other mappings" do
    it "should map the order id" do
      param!("Referencia", "ABCDEF")
      @notification.order_id.should == "ABCDEF"
    end
    
    it "should map the processing date" do
      param!("DataTransacao", "04/09/2009 16:23:44")
      @notification.processed_at.should == Time.parse("2009-09-04 16:23:44").utc
    end
    
    it "should map the shipping type" do
      param!("TipoFrete", "SD")
      @notification.shipping_type.should == "SD"
    end
    
    it "should map the client annotation" do
      param!("Anotacao", "Gift package, please!")
      @notification.notes.should == "Gift package, please!"
    end
    
    it "should map the shipping price" do
      param!("ValorFrete", "199,38")
      @notification.shipping.should == 199.38
      
      param!("ValorFrete", "1.799,38")
      @notification.shipping.should == 1799.38
    end
    
    it "should map the transaction id" do
      param!("TransacaoID", "ABCDEF")
      @notification.transaction_id.should == "ABCDEF"
    end
  end
  
  describe "products" do
    before(:each) do
      @__products = []
    end
    
    it "should map 5 products" do
      param!("NumItens", "5")
      @notification.products.should have(5).items
    end
    
    it "should map 25 products" do
      param!("NumItens", "25")
      @notification.products.should have(25).items
    end
    
    it "should set attributes with defaults" do
      set_product! :description => "Ruby 1.9 PDF", :price => "12,90", :id => 1
      p = @notification.products.first

      p[:description].should == "Ruby 1.9 PDF"
      p[:price].should == 12.90
      p[:id].should == "1"
      p[:quantity].should == 1
      p[:fees].should be_zero
      p[:shipping].should be_zero
    end
    
    it "should set attributes with custom values" do
      set_product!({
        :description => "Rails Application Templates", 
        :price => "1,00",
        :id => 8,
        :fees => "2,53",
        :shipping => "3,50",
        :quantity => 10
      })
      
      p = @notification.products.first

      p[:description].should == "Rails Application Templates"
      p[:price].should == 1.00
      p[:id].should == "8"
      p[:quantity].should == 10
      p[:fees].should == 2.53
      p[:shipping].should == 3.50
    end
  end
  
  describe "confirmation" do
    before(:each) do
      PagSeguro.stub!(:developer?).and_return(false)
      @url = PagSeguro::Notification::API_URL
      @notification.stub!(:api_url).and_return(@url)
    end
    
    it "should be valid" do
      FakeWeb.register_uri(:post, @url, :body => "VERIFICADO")
      @notification.should be_valid
    end
    
    it "should be invalid" do
      FakeWeb.register_uri(:post, @url, :body => "")
      @notification.should_not be_valid
    end
    
    it "should force validation" do
      FakeWeb.register_uri(:post, @url, :body => "")
      @notification.should_not be_valid
      
      FakeWeb.register_uri(:post, @url, :body => "VERIFICADO")
      @notification.should_not be_valid
      @notification.should be_valid(:nocache)
    end
    
    it "should set the authenticity token from the initialization" do
      notification = PagSeguro::Notification.new(@the_params, 'ABCDEF')
      
      post = mock("post").as_null_object
      post.should_receive(:set_form_data).with({:Comando => "validar", :Token => "ABCDEF"})
      
      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)
      
      notification.valid?
    end

    it "should set the authenticity token from the configuration" do
      PagSeguro.stub!(:config).and_return("authenticity_token" => "ABCDEF")
      
      post = mock("post").as_null_object
      post.should_receive(:set_form_data).with({:Comando => "validar", :Token => "ABCDEF"})
      
      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)
      
      @notification.valid?
    end
    
    it "should propagate params" do
      param!("VendedorEmail", "john@doe.com")
      param!("NumItens", "14")
      PagSeguro.stub!(:config).and_return("authenticity_token" => "ABCDEF")
      
      post = mock("post").as_null_object
      post.should_receive(:set_form_data).with({
        :Comando => "validar", 
        :Token => "ABCDEF", 
        "VendedorEmail" => "john@doe.com",
        "NumItens" => "14"
      })
      
      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)
      
      @notification.valid?
    end

    it "should propagate params in ISO-8859-1" do
      param!("CliNome", "João Doão")
      PagSeguro.stub!(:config).and_return("authenticity_token" => "ABCDEF")
      
      post = mock("post").as_null_object
      post.should_receive(:set_form_data).with({
        :Comando => "validar", 
        :Token => "ABCDEF", 
        "CliNome" => to_iso("João Doão")
      })
      
      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)
      
      @notification.valid?
    end
  end
  
  private
    def set_status!(value)
      param!("StatusTransacao", value)
    end
    
    def set_payment!(value)
      param!("TipoPagamento", value)
    end
    
    def param!(name, value)
      @notification.params.merge!(name => value)
    end
    
    def to_iso(str)
      str.unpack('U*').pack('C*')
    end

    def set_product!(options={})
      @__products ||= []
      
      i = @__products.size + 1
      
      options = {
        :quantity => 1,
        :fees => "0,00",
        :shipping => "0,00"
      }.merge(options)
      
      @__products << {
        "ProdID_#{i}" => options[:id].to_s,
        "ProdDescricao_#{i}" => options[:description].to_s,
        "ProdValor_#{i}" => options[:price].to_s,
        "ProdFrete_#{i}" => options[:shipping].to_s,
        "ProdExtras_#{i}" => options[:fees].to_s,
        "ProdQuantidade_#{i}" => options[:quantity].to_s
      }
      
      @notification.params.merge!(@__products.last)
      @notification.params.merge!("NumItens" => i)
      @__products.last
    end
end
