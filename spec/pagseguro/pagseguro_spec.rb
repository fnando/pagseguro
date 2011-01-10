require "spec_helper"

describe PagSeguro do
  describe "configuration" do
    before do
      @config_file = Rails.root.join("config/pagseguro.yml")
      @contents = YAML.load_file(@config_file)
      File.stub!(:exists?).and_return(true)
      YAML.stub!(:load_file).and_return(@contents)

      module PagSeguro; @@config = nil; end
    end

    it "should raise error if configuration is not found" do
      File.should_receive(:exist?).with(@config_file).and_return(false)
      expect { PagSeguro.config }.to raise_error(PagSeguro::MissingConfigurationError)
    end

    it "should raise error if no environment is set on config file" do
      YAML.should_receive(:load_file).with(@config_file).and_return({})
      expect { PagSeguro.config }.to raise_error(PagSeguro::MissingEnvironmentError)
    end

    it "should raise error if config file is empty" do
      # YAML.load_file return false when file is zero-byte
      YAML.should_receive(:load_file).with(@config_file).and_return(false)
      expect { PagSeguro.config }.to raise_error(PagSeguro::MissingEnvironmentError)
    end

    it "should return local url if developer mode is enabled" do
      PagSeguro.should_receive(:developer?).and_return(true)
      PagSeguro.gateway_url.should == "/pagseguro_developer"
    end

    it "should return real url if developer mode is disabled" do
      PagSeguro.should_receive(:developer?).and_return(false)
      PagSeguro.gateway_url.should == "https://pagseguro.uol.com.br/security/webpagamentos/webpagto.aspx"
    end

    it "should read configuration developer mode" do
      PagSeguro.stub!(:config).and_return("developer" => true)
      PagSeguro.should be_developer

      PagSeguro.stub!(:config).and_return("developer" => false)
      PagSeguro.should_not be_developer
    end
  end
end