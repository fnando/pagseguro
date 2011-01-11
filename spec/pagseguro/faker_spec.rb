require "spec_helper"

describe PagSeguro::Faker do
  it "should return city" do
    PagSeguro::Faker::CITIES.should include(PagSeguro::Faker.city)
  end

  it "should return state" do
    PagSeguro::Faker::STATES.should include(PagSeguro::Faker.state)
  end

  it "should return street name" do
    PagSeguro::Faker::STREET_TYPES.stub :sample => "Alameda"
    PagSeguro::Faker::CITIES.stub :sample => "Horizontina"
    PagSeguro::Faker.street_name.should == "Alameda Horizontina"
  end

  it "should return secondary address" do
    PagSeguro::Faker::SECONDARY_ADDRESS.stub :sample => "Apto"
    PagSeguro::Faker.stub :rand => 666
    PagSeguro::Faker.secondary_address.should == "Apto 666"
  end

  it "should return name" do
    PagSeguro::Faker::NAMES.should include(PagSeguro::Faker.name)
  end

  it "should return surname" do
    PagSeguro::Faker::SURNAMES.should include(PagSeguro::Faker.surname)
  end

  it "should return full name" do
    PagSeguro::Faker.stub :name => "John"
    PagSeguro::Faker.stub :surname => "Doe"
    PagSeguro::Faker.full_name.should == "John Doe"
  end

  it "should return email" do
    PagSeguro::Faker.stub :full_name => "John Doe"
    PagSeguro::Faker.email.should match(/john.doe@(gmail|yahoo|hotmail|uol|ig|bol)/)
  end

  it "should return phone number" do
    PagSeguro::Faker.phone_number.should match(/\(\d{2}\) \d{4}-\d{4}/)
  end

  it "should return zip code" do
    PagSeguro::Faker.zipcode.should match(/\d{5}-\d{3}/)
  end
end
