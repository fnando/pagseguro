RSpec::Matchers.define :have_input do |options|
  match do |html|
    options.reverse_merge!(:type => "hidden")

    selector = "input"
    selector << "[type=#{options[:type]}]"
    selector << "[name=#{options[:name]}]" if options[:name]

    input = html.css(selector).first

    if options[:value]
      input && input[:value] == options[:value]
    else
      input != nil
    end
  end

  failure_message_for_should do |html|
    "expected #{html.to_s} to have a field with attributes #{options.inspect}"
  end

  failure_message_for_should_not do |html|
    "expected #{html.to_s} to have no field with attributes #{options.inspect}"
  end
end

RSpec::Matchers.define :have_attr do |name, value|
  match do |html|
    html[name] == value
  end

  failure_message_for_should do |html|
    "expected #{html.to_s} to have a #{name.inspect} with value #{value.inspect}"
  end

  description do
    "should have attribute #{name.inspect} with value #{value.inspect}"
  end
end
