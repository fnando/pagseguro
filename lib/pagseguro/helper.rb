module PagSeguro::Helper
  def pagseguro_form(order, options = {})
    options.reverse_merge!(:submit => "Pagar com PagSeguro")
    render :partial => "/pagseguro_form", :locals => {:options => options, :order => order}
  end
end
