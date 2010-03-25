module PagseguroHelper
  PAGSEGURO_FORM_VIEW = File.expand_path(File.dirname(__FILE__) + "/views/_form.html.erb")
  
  def pagseguro_form(order, options={})
    options = {
      :submit => "Pagar com PagSeguro"
    }.merge(options)

    render :file => PAGSEGURO_FORM_VIEW, :locals => {:options => options, :order => order}
  end
end
