module PagSeguro::Helper
  def pagseguro_form(order, value = "Pagar com PagSeguro", options = {})
    render :partial => "pagseguro/pagseguro_form", :locals => {:value => value, :options => options, :order => order}
  end
end
