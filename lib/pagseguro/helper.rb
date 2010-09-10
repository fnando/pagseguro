module PagSeguro::Helper
  PAGSEGURO_FORM_VIEW = File.expand_path(File.dirname(__FILE__) + "/views/_form.html.erb")

  def pagseguro_form(order, options = {})
    options.reverse_merge!(:submit => "Pagar com PagSeguro")
    render :file => PAGSEGURO_FORM_VIEW, :locals => {:options => options, :order => order}
  end
end
