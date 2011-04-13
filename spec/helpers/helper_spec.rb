# -*- encoding: utf-8 -*-
require "spec_helper"

describe PagSeguro::Helper do
  before do
    @order = PagSeguro::Order.new("I1001")
    PagSeguro.stub :developer?
  end

  subject {
    Nokogiri::HTML(helper.pagseguro_form(@order)).css("form").first
  }

  context "with default attributes" do
    it { should have_attr("action", PagSeguro::GATEWAY_URL) }
    it { should have_attr("class", "pagseguro") }
    it { should have_input(:name => "encoding", :value => "UTF-8") }
    it { should have_input(:name => "tipo", :value => "CP") }
    it { should have_input(:name => "moeda", :value => "BRL") }
    it { should have_input(:name => "ref_transacao", :value => "I1001") }
    it { should_not have_input(:name => "tipo_frete") }
    it { should have_input(:name => "email_cobranca", :value => "john@doe.com") }
    it { should have_input(:type => "submit", :value => "Pagar com PagSeguro") }
  end

  it "should include shipping type" do
    @order.shipping_type = "SD"
    subject.should have_input(:name => "tipo_frete", :value => "SD")
  end

  context "with custom attributes" do
    subject {
      Nokogiri::HTML(helper.pagseguro_form(@order, :submit => "Pague agora!", :email => "mary@example.com")).css("form").first
    }

    it { should have_input(:name => "email_cobranca", :value => "mary@example.com") }
    it { should have_input(:type => "submit", :value => "Pague agora!") }
  end

  context "with minimum product info" do
    before do
      @order << { :id => 1001, :price => 10.00, :description => "Rails 3 e-Book" }
    end

    it { should have_input(:name => "item_quant_1", :value => "1") }
    it { should have_input(:name => "item_id_1", :value => "1001") }
    it { should have_input(:name => "item_valor_1", :value => "1000") }
    it { should have_input(:name => "item_descr_1", :value => "Rails 3 e-Book") }
    it { should_not have_input(:name => "item_peso_1") }
    it { should_not have_input(:name => "item_frete_1") }
  end

  context "with optional product info" do
    before do
      @order << { :id => 1001, :price => 10.00, :description => "T-Shirt", :weight => 300, :shipping => 8.50, :quantity => 2 }
    end

    it { should have_input(:name => "item_quant_1", :value => "2") }
    it { should have_input(:name => "item_peso_1", :value => "300") }
    it { should have_input(:name => "item_frete_1", :value => "850") }
  end

  context "with multiple products" do
    before do
      @order << { :id => 1001, :price => 10.00, :description => "Rails 3 e-Book" }
      @order << { :id => 1002, :price => 19.00, :description => "Rails 3 e-Book + Screencast" }
    end

    it { should have_input(:name => "item_quant_1", :value => "1") }
    it { should have_input(:name => "item_id_1", :value => "1001") }
    it { should have_input(:name => "item_valor_1", :value => "1000") }
    it { should have_input(:name => "item_descr_1", :value => "Rails 3 e-Book") }

    it { should have_input(:name => "item_quant_2", :value => "1") }
    it { should have_input(:name => "item_id_2", :value => "1002") }
    it { should have_input(:name => "item_valor_2", :value => "1900") }
    it { should have_input(:name => "item_descr_2", :value => "Rails 3 e-Book + Screencast") }
  end

  context "with billing info" do
    before do
      @order.billing = {
        :name => "John Doe",
        :email => "john@doe.com",
        :address_zipcode => "01234-567",
        :address_street => "Rua Orobó",
        :address_number => 72,
        :address_complement => "Casa do fundo",
        :address_neighbourhood => "Tenório",
        :address_city => "Pantano Grande",
        :address_state => "AC",
        :address_country => "Brasil",
        :phone_area_code => "22",
        :phone_number => "1234-5678"
      }
    end

    it { should have_input(:name => "cliente_nome", :value => "John Doe") }
    it { should have_input(:name => "cliente_email", :value => "john@doe.com") }
    it { should have_input(:name => "cliente_cep", :value => "01234-567") }
    it { should have_input(:name => "cliente_end", :value => "Rua Orobó") }
    it { should have_input(:name => "cliente_num", :value => "72") }
    it { should have_input(:name => "cliente_compl", :value => "Casa do fundo") }
    it { should have_input(:name => "cliente_bairro", :value => "Tenório") }
    it { should have_input(:name => "cliente_cidade", :value => "Pantano Grande") }
    it { should have_input(:name => "cliente_uf", :value => "AC") }
    it { should have_input(:name => "cliente_pais", :value => "Brasil") }
    it { should have_input(:name => "cliente_ddd", :value => "22") }
    it { should have_input(:name => "cliente_tel", :value => "1234-5678") }
  end
end
