# encoding: utf-8
require "spec_helper"

describe PagSeguro::Notification do
  subject { PagSeguro::Notification.new(@the_params) }
  let(:payload) { YAML.load_file File.dirname(__FILE__) + "/../fixtures/notification.yml" }
  before { @the_params = {} }

  it "should not request the confirmation url when running developer mode" do
    PagSeguro.stub :developer? => true
    Net::HTTP.should_not_receive(:new)
    subject.should be_valid
  end

  describe "#to_hash" do
    subject { PagSeguro::Notification.new(payload) }

    PagSeguro::Notification::MAPPING.each do |name, value|
      it "includes #{name}" do
        subject.to_hash.should have_key(name)
        subject.to_hash[name].should_not be_nil
      end
    end
  end

  describe "status mapping" do
    it "should be completed" do
      set_status!("Completo")
      subject.status.should == :completed
    end

    it "should be pending" do
      set_status!("Aguardando Pagto")
      subject.status.should == :pending
    end

    it "should be approved" do
      set_status!("Aprovado")
      subject.status.should == :approved
    end

    it "should be verifying" do
      set_status!("Em Análise")
      subject.status.should == :verifying
    end

    it "should be canceled" do
      set_status!("Cancelado")
      subject.status.should == :canceled
    end

    it "should be refunded" do
      set_status!("Devolvido")
      subject.status.should == :refunded
    end
  end

  describe "payment mapping" do
    it "should be credit card" do
      set_payment!("Cartão de Crédito")
      subject.payment_method.should == :credit_card
    end

    it "should be invoice" do
      set_payment!("Boleto")
      subject.payment_method.should == :invoice
    end

    it "should be pagseguro" do
      set_payment!("Pagamento")
      subject.payment_method.should == :pagseguro
    end

    it "should be online transfer" do
      set_payment!("Pagamento Online")
      subject.payment_method.should == :online_transfer
    end

    it "should be donation" do
      set_payment!("Doação")
      subject.payment_method.should == :donation
    end
  end

  describe "buyer mapping" do
    it "should return client name" do
      param!("CliNome", "John Doe")
      subject.buyer[:name].should == "John Doe"
    end

    it "should return client email" do
      param!("CliEmail", "john@doe.com")
      subject.buyer[:email].should == "john@doe.com"
    end

    it "should return client phone" do
      param!("CliTelefone", "11 55551234")
      subject.buyer[:phone][:area_code].should == "11"
      subject.buyer[:phone][:number].should == "55551234"
    end

    describe "address" do
      it "should return street" do
        param!("CliEndereco", "Av. Paulista")
        subject.buyer[:address][:street].should == "Av. Paulista"
      end

      it "should return number" do
        param!("CliNumero", "2500")
        subject.buyer[:address][:number].should == "2500"
      end

      it "should return complements" do
        param!("CliComplemento", "Apto 123-A")
        subject.buyer[:address][:complements].should == "Apto 123-A"
      end

      it "should return neighbourhood" do
        param!("CliBairro", "Bela Vista")
        subject.buyer[:address][:neighbourhood].should == "Bela Vista"
      end

      it "should return city" do
        param!("CliCidade", "São Paulo")
        subject.buyer[:address][:city].should == "São Paulo"
      end

      it "should return state" do
        param!("CliEstado", "SP")
        subject.buyer[:address][:state].should == "SP"
      end

      it "should return postal code" do
        param!("CliCEP", "01310300")
        subject.buyer[:address][:postal_code].should == "01310300"
      end
    end
  end

  describe "other mappings" do
    it "should map the order id" do
      param!("Referencia", "ABCDEF")
      subject.order_id.should == "ABCDEF"
    end

    it "should map the processing date" do
      param!("DataTransacao", "04/09/2009 16:23:44")
      subject.processed_at.should == Time.parse("2009-09-04 16:23:44").utc
    end

    it "should map the shipping type" do
      param!("TipoFrete", "SD")
      subject.shipping_type.should == "SD"
    end

    it "should map the client annotation" do
      param!("Anotacao", "Gift package, please!")
      subject.notes.should == "Gift package, please!"
    end

    it "should map the shipping price" do
      param!("ValorFrete", "199,38")
      subject.shipping.should == 199.38

      param!("ValorFrete", "1.799,38")
      subject.shipping.should == 1799.38
    end

    it "should map the transaction id" do
      param!("TransacaoID", "ABCDEF")
      subject.transaction_id.should == "ABCDEF"
    end
  end

  describe "products" do
    before do
      @__products = []
    end

    it "should map 5 products" do
      param!("NumItens", "5")
      subject.products.should have(5).items
    end

    it "should map 25 products" do
      param!("NumItens", "25")
      subject.products.should have(25).items
    end

    it "should set attributes with defaults" do
      set_product! :description => "Ruby 1.9 PDF", :price => "12,90", :id => 1
      p = subject.products.first

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

      p = subject.products.first

      p[:description].should == "Rails Application Templates"
      p[:price].should == 1.00
      p[:id].should == "8"
      p[:quantity].should == 10
      p[:fees].should == 2.53
      p[:shipping].should == 3.50
    end

    specify "bug fix: should work correctly when price is 0.9" do
      set_product!({
        :price => ",90",
      })

      p = subject.products.first

      p[:price].should == 0.9
    end
  end

  describe "confirmation" do
    before do
      PagSeguro.stub :developer? => false
      @url = PagSeguro::Notification::API_URL
      subject.stub :api_url => @url
    end

    it "should be valid" do
      FakeWeb.register_uri(:post, @url, :body => "VERIFICADO")
      subject.should be_valid
    end

    it "should be invalid" do
      FakeWeb.register_uri(:post, @url, :body => "")
      subject.should_not be_valid
    end

    it "should force validation" do
      FakeWeb.register_uri(:post, @url, :body => "")
      subject.should_not be_valid

      FakeWeb.register_uri(:post, @url, :body => "VERIFICADO")
      subject.should_not be_valid
      subject.should be_valid(:nocache)
    end

    it "should set the authenticity token from the initialization" do
      notification = PagSeguro::Notification.new(@the_params, 'ABCDEF')

      post = mock("post").as_null_object
      post.should_receive(:form_data=).with({:Comando => "validar", :Token => "ABCDEF"})

      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)

      notification.valid?
    end

    it "should set the authenticity token from the configuration" do
      PagSeguro.stub :config => {"authenticity_token" => "ABCDEF"}

      post = mock("post").as_null_object
      post.should_receive(:form_data=).with({:Comando => "validar", :Token => "ABCDEF"})

      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)

      subject.valid?
    end

    it "should propagate params" do
      param!("VendedorEmail", "john@doe.com")
      param!("NumItens", "14")
      PagSeguro.stub :config => {"authenticity_token" => "ABCDEF"}

      post = mock("post").as_null_object
      post.should_receive(:form_data=).with({
        :Comando => "validar",
        :Token => "ABCDEF",
        "VendedorEmail" => "john@doe.com",
        "NumItens" => "14"
      })

      Net::HTTP.should_receive(:new).and_return(mock("http").as_null_object)
      Net::HTTP::Post.should_receive(:new).and_return(post)

      subject.valid?
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
    subject.params.merge!(name => value)
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

    subject.params.merge!(@__products.last)
    subject.params.merge!("NumItens" => i)
    @__products.last
  end
end
